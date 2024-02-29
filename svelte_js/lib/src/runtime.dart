@JS(r'$$')
library;

import 'dart:js_interop';

import 'package:svelte_js/src/types.dart';

@JS('get')
external JSBoxedDartObject? _get(JSObject signal);

T get<T>(Signal<T> signal) {
  var boxed = _get(signal);
  return boxed?.toDart as T;
}

@JS('set')
external JSBoxedDartObject? _set(JSObject signal, JSBoxedDartObject? value);

T set<T>(Signal<T> signal, T? value) {
  var boxed = _set(signal, value?.toJSBox);
  return boxed?.toDart as T;
}

@JS('untrack')
external JSBoxedDartObject? _untrack(JSFunction function);

T untrack<T>(T Function() function) {
  JSBoxedDartObject? wrapper() {
    var result = function() as T?;
    return result?.toJSBox;
  }

  var boxed = _untrack(wrapper.toJS);
  return boxed?.toDart as T;
}

@JS('push')
external void _push(JSObject properties, [JSBoolean? runes]);

void push(JSObject properties, [bool? runes]) {
  if (runes == null) {
    _push(properties);
  } else {
    _push(properties, runes.toJS);
  }
}

@JS('pop')
external void _pop([JSObject? component]);

void pop([JSObject? component]) {
  if (component == null) {
    _pop();
  } else {
    _pop(component);
  }
}

@JS('init')
external void _init();

void init() {
  _init();
}
