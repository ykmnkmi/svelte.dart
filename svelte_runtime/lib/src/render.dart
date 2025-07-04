import 'dart:async';
import 'dart:js_interop';

import 'package:svelte_runtime/src/component.dart';
import 'package:svelte_runtime/src/dom.dart';
import 'package:svelte_runtime/src/reactivity.dart';
import 'package:svelte_runtime/src/runtime.dart';
import 'package:svelte_runtime/src/shared.dart';
import 'package:svelte_runtime/src/unsafe_cast.dart';
import 'package:web/web.dart';

// This is normally `true` — block effects should run their intro transitions —
// but is false during hydration (unless `intro` is `true`) and when
// creating the children of a `<svelte:element>` that just changed tag.
bool shouldIntro = true;

void setShouldIntro(bool value) {
  shouldIntro = value;
}

void setText(Text text, String value) {
  String currentValue = text.t__ ??= text.nodeValue ?? '';

  if (value != currentValue) {
    text
      ..nodeValue = value
      ..t__ = value;
  }
}

/// Hydrates a component on the given target.
Future<void> Function([bool outro]) hydrate(
  Component component, {
  required Element target,
  Map<Object, Object>? context,
  bool intro = false,
  bool recover = false,
}) {
  init();

  bool wasHydrating = hydrating;
  Node? previousHydrateNode = hydrateNode;

  try {
    Comment? anchor = getFirstChild<Comment?>(target);

    while (anchor != null &&
        (anchor.nodeType != 8 || anchor.data != hydrationStart)) {
      anchor = getNextSibling<Comment>(anchor);
    }

    if (anchor == null) {
      throw hydrationError;
    }

    setHydrating(true);
    setHydrateNode<Node?>(anchor);
    hydrateNext<Node?>();

    Future<void> Function([bool outro]) unmount = mount(
      component,
      target: target,
      anchor: anchor,
      context: context,
      intro: intro,
    );

    if (hydrateNode == null ||
        unsafeCast<Node>(hydrateNode).nodeType != 8 ||
        unsafeCast<Comment>(hydrateNode).data != hydrationEnd) {
      // ignore: avoid_print
      print('WRN_HYDRATION_MISMATCH');
      throw hydrationError;
    }

    setHydrating(false);
    return unmount;
  } catch (error) {
    if (error == hydrationError) {
      if (!recover) {
        throw StateError('ERR_HYDRATION_FAILED');
      }

      init(); // re-init
      clearTextContent(target);
      setHydrating(false);
      return mount(
        component,
        target: target,
        context: context,
        intro: intro,
      );
    }

    rethrow;
  } finally {
    setHydrating(wasHydrating);
    setHydrateNode<Node?>(previousHydrateNode);
    resetHeadAnchor();
  }
}

Map<String, int> documentListeners = <String, int>{};

/// Mounts a component to the given target.
///
/// Transitions will play during the initial render unless the [intro] option is
/// set to `false`.
Future<void> Function([bool outro]) mount(
  Component component, {
  required Element target,
  Node? anchor,
  Map<Object, Object>? context,
  bool intro = true,
}) {
  init();

  Set<String> registeredEvents = <String>{};
  JSExportedDartFunction jsHandle = handleEventPropagation.toJSCaptureThis;

  void eventHandle(Iterable<String> events) {
    for (String event in events) {
      if (!registeredEvents.add(event)) {
        continue;
      }

      bool passive = isPassiveEvent(event);
      JSObject addOptions = AddEventListenerOptions(passive: passive);

      // Add the event listener to both the container and the document.
      // The container listener ensures we catch events from within in case the
      // outer content stops propagation of the event.
      target.addEventListener(event, jsHandle, addOptions);

      int? n = documentListeners[event];

      if (n == null) {
        // The document listener ensures we catch events that originate from
        // elements that were manually moved outside of the container (e.g. via
        // manual portals).
        document.addEventListener(event, jsHandle, addOptions);
        documentListeners[event] = 1;
      } else {
        documentListeners[event] = n + 1;
      }
    }
  }

  eventHandle(allRegisteredEvents);
  rootEventHandles.add(eventHandle);

  return componentRoot(() {
    Node anchorNode = anchor ?? appendChild(target, createText());

    branch<void>(() {
      if (context != null) {
        componentContext!.context = context;
      }

      if (hydrating) {
        assignNodes(anchorNode, null);
      }

      setShouldIntro(intro);
      component.create(anchorNode);
      setShouldIntro(true);

      if (hydrating) {
        activeEffect!.nodeEnd = hydrateNode;
      }

      if (context != null) {
        pop();
      }
    });

    return () {
      for (String event in registeredEvents) {
        target.removeEventListener(event, jsHandle);

        int? n = documentListeners[event];

        if (n != null) {
          if (--n == 0) {
            document.removeEventListener(event, jsHandle);
            documentListeners.remove(event);
          } else {
            documentListeners[event] = n;
          }
        }
      }

      rootEventHandles.remove(eventHandle);

      if (anchorNode != anchor) {
        remove(anchorNode);
      }
    };
  });
}
