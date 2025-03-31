import 'dart:js_interop';

import 'package:svelte_runtime/src/dom/elements/misc.dart';
import 'package:svelte_runtime/src/reactivity.dart';
import 'package:svelte_runtime/src/runtime.dart';
import 'package:web/web.dart';

void listen(
  EventTarget target,
  List<String> events,
  void Function() handler, [
  bool callHandlerImmediately = true,
]) {
  if (callHandlerImmediately) {
    handler();
  }

  JSExportedDartFunction jsHandler = handler.toJS;

  for (int i = 0; i < events.length; i++) {
    target.addEventListener(events[i], jsHandler);
  }

  teardown<void>(() {
    for (int i = 0; i < events.length; i++) {
      target.removeEventListener(events[i], jsHandler);
    }
  });
}

T withoutReactiveContext<T>(T Function() callback) {
  var previousReaction = activeReaction;
  var previousEffect = activeEffect;
  setActiveReaction(null);
  setActiveEffect(null);

  try {
    return callback();
  } finally {
    setActiveReaction(previousReaction);
    setActiveEffect(previousEffect);
  }
}

// Listen to the given event, and then instantiate a global form reset listener
// if not already done, to notify all bindings when the form is reset.
void listenToEventAndResetEvent(
  HTMLElement element,
  String event,
  void Function(bool isReset) handler, [
  void Function(bool isReset)? onReset,
]) {
  element.addEventListener(
    event,
    () {
      withoutReactiveContext<void>(() {
        handler(false);
      });
    }.toJS,
  );

  onReset ??= handler;

  void Function(bool isReset)? previous = element.onReset__;

  if (previous == null) {
    element.onReset__ = (bool isReset) {
      onReset!(true);
    };
  } else {
    // Special case for checkbox that can have multiple binds (group & checked).
    element.onReset__ = (bool isReset) {
      previous(false);
      onReset!(true);
    };
  }

  addFormResetListener();
}

extension HTMLElementOnReset on HTMLElement {
  @JS('__on_r')
  external ExternalDartReference<void Function(bool isReset)?> onResetReference;

  // ignore: non_constant_identifier_names
  void Function(bool isReset)? get onReset__ {
    return this.onResetReference.toDartObject;
  }

  // ignore: non_constant_identifier_names
  set onReset__(void Function(bool isReset)? onReset) {
    this.onResetReference = onReset.toExternalReference;
  }
}
