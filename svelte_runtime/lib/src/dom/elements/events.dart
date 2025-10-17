import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:svelte_runtime/src/dom/elements/bindings/shared.dart';
import 'package:svelte_runtime/src/interop.dart';
import 'package:svelte_runtime/src/reactivity.dart';
import 'package:svelte_runtime/src/runtime.dart';
import 'package:svelte_runtime/src/tasks.dart';
import 'package:svelte_runtime/src/unsafe_cast.dart';
import 'package:web/web.dart';

typedef EventsHandle = void Function(Iterable<String> events);

Set<String> allRegisteredEvents = <String>{};

Set<EventsHandle> rootEventHandles = <EventsHandle>{};

JSExportedDartFunction createEvent<E extends Element, T extends Event>(
  String eventName,
  Element element,
  void Function(E element, T event) handler,
  bool capture, [
  bool passive = false,
]) {
  void targetHandler(Element handledElement, Event event) {
    if (!capture) {
      // Only call in the bubble phase, else delegated events would be called
      // before the capturing events.
      handleEventPropagation(element, event);
    }

    if (!event.cancelBubble) {
      withoutReactiveContext(() {
        handler(unsafeCast<E>(handledElement), unsafeCast<T>(event));
      });
    }
  }

  JSExportedDartFunction jsTargetHandler = targetHandler.toJSCaptureThis;

  AddEventListenerOptions jsOptions = AddEventListenerOptions(
    capture: capture,
    passive: passive,
  );

  // Chrome has a bug where pointer events don't work when attached to a DOM
  // element that has been cloned with cloneNode() and the DOM element is
  // disconnected from the document. To ensure the event works, we defer the
  // attachment till after it's been appended to the document.
  //
  // TODO(events): remove this once Chrome fixes this bug. The same applies to
  //  wheel events and touch events.
  if (eventName.startsWith('pointer') ||
      eventName.startsWith('touch') ||
      eventName == 'wheel') {
    queueMicroTask(() {
      element.addEventListener(eventName, jsTargetHandler, jsOptions);
    });
  } else {
    element.addEventListener(eventName, jsTargetHandler, jsOptions);
  }

  return jsTargetHandler;
}

void eventVoid(
  String eventName,
  Element element,
  void Function() handler, [
  bool capture = false,
  bool passive = false,
]) {
  eventThis<Element, Event>(
    eventName,
    element,
    (_, _) => handler(),
    capture,
    passive,
  );
}

void event<T extends Event>(
  String eventName,
  Element element,
  void Function(T event) handler, [
  bool capture = false,
  bool passive = false,
]) {
  eventThis<Element, T>(
    eventName,
    element,
    (_, event) => handler(event),
    capture,
    passive,
  );
}

void eventThis<E extends Element, T extends Event>(
  String eventName,
  Element element,
  void Function(E element, T event) handler, [
  bool capture = false,
  bool passive = false,
]) {
  JSExportedDartFunction jsTargetHandler = createEvent<E, T>(
    eventName,
    element,
    handler,
    capture,
    passive,
  );

  if (element == document.body || element == window || element == document) {
    teardown<void>(() {
      EventListenerOptions jsCptions = EventListenerOptions(capture: capture);
      element.removeEventListener(eventName, jsTargetHandler, jsCptions);
    });
  }
}

void delegate(Iterable<String> events) {
  allRegisteredEvents.addAll(events);

  for (EventsHandle handle in rootEventHandles) {
    handle(events);
  }
}

void handleEventPropagation(Element element, Event event) {
  Document? owner = element.ownerDocument;
  String eventName = event.type;
  JSArray<EventTarget> jsPath = event.composedPath();
  Element? target = unsafeCast<Element>(jsPath[0]);

  // `composedPath` contains list of nodes the event has propagated through.
  // We check `root` to skip all nodes below it in case this is a parent of the
  // `root` node, which indicates that there's nested mounted apps. In this case
  // we don't want to trigger events multiple times.
  int pathIndex = 0;

  Element? handledAt = event.root__;

  if (handledAt != null) {
    int atIndex = jsPath.indexOf(handledAt);

    if (atIndex != -1 && (element == document || element == window)) {
      // This is the fallback document listener or a window listener, but the
      // event was already handled -> ignore, but set handleAt to document or
      // window so that we're resetting the event chain in case someone manually
      // dispatches the same event object again.
      event.root__ = element;
      return;
    }

    // We're deliberately not skipping if the index is higher, because someone
    // could create an event programmatically and emit it multiple times, in
    // which case we want to handle the whole propagation chain properly each
    // time. This will only be a false negative if the event is dispatched
    // multiple times and the fallback document listener isn't reached in
    // between, but that's super rare.
    int handlerIndex = jsPath.indexOf(element);

    if (handlerIndex == -1) {
      // `handlerIndex` can theoretically be -1 (happened in some JSDOM testing
      // scenarios with an event listener on the window object) so guard against
      // that, too, and assume that everything was handled at this point.
      return;
    }

    if (atIndex <= handlerIndex) {
      pathIndex = atIndex;
    }
  }

  target = unsafeCast<Element?>(
    pathIndex < jsPath.length ? jsPath[pathIndex] : event.target,
  );

  // There can only be one delegated event per element, and we either already
  // handled the current target, or this is the very first target in the chain
  // which has a non-delegated listener, in which case it's safe to handle a
  // possible delegated event on it later (through the root delegation listener
  // for example).
  if (target == element) {
    return;
  }

  // Proxy currentTarget to correct target.
  EventTarget? getCurrentTarget() {
    return target ?? owner;
  }

  PropertyDescriptor descriptor = PropertyDescriptor(
    configurable: true,
    get: getCurrentTarget.toJS,
  );

  defineProperty(event, 'currentTarget', descriptor);

  // This started because of Chromium issue
  // https://chromestatus.com/feature/5128696823545856, where removal or moving
  // of of the DOM can cause sync `blur` events to fire, which can cause logic
  // to run inside the current `activeReaction`, which isn't what we want at
  // all. However, on reflection, it's probably best that all event handled by
  // Svelte have this behaviour, as we don't really want an event handler to run
  // in the context of another reaction or effect.
  Reaction? previousReaction = activeReaction;
  Effect? previousEffect = activeEffect;
  setActiveReaction(null);
  setActiveEffect(null);

  try {
    Object? firstError;

    List<Object> errors = <Object>[];

    while (target != null) {
      Element? parent =
          target.assignedSlot ?? target.parentElement ?? target.hostNullable;

      try {
        JSAny? jsDelegateReference = target['__$eventName'];
        ExternalDartReference<void Function(Event)>? delegateReference =
            unsafeCast<ExternalDartReference<void Function(Event)>?>(
              jsDelegateReference,
            );

        if (delegateReference != null && !(target.disabledNullable ?? false)) {
          delegateReference.toDartObject(event);
        }
      } catch (error) {
        if (firstError == null) {
          firstError = error;
        } else {
          errors.add(error);
        }
      }

      if (event.cancelBubble || parent == element || parent == null) {
        break;
      }

      target = parent;
    }

    if (firstError != null) {
      for (int i = 0; i < errors.length; i++) {
        // Throw the rest of the errors, one-by-one on a microtask.
        queueMicroTask(() {
          throw errors[i];
        });
      }

      throw firstError;
    }
  } finally {
    event.root__ = element;
    event.delete('currentTarget'.toJS);
    setActiveReaction(previousReaction);
    setActiveEffect(previousEffect);
  }
}

extension on Event {
  @JS('__root')
  // ignore: non_constant_identifier_names
  external Element? root__;
}

extension on Element {
  @JS('host')
  external Element? get hostNullable;

  @JS('disabled')
  external bool? get disabledNullable;
}

extension on JSArray<EventTarget> {
  external int indexOf(EventTarget searchElement);
}
