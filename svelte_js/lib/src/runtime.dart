@JS(r'$$')
library;

import 'dart:js_interop';

import 'package:svelte_js/src/types.dart';
import 'package:svelte_js/src/unsafe_cast.dart';

@JS('get')
external JSAny? _get(JSObject signal);

V get<V>(Signal<V> signal) {
  return unsafeCast<V>(_get(signal.ref));
}

@JS('set')
external JSAny? _set(JSObject signal, JSAny? value);

V set<V>(Signal<V> signal, V value) {
  return unsafeCast<V>(_set(signal.ref, unsafeCast<JSAny?>(value)));
}

@JS('mutable_source')
external JSObject _mutableSource(JSAny? value);

SourceSignal<V> mutableSource<V>(V value) {
  return SourceSignal<V>(_mutableSource(unsafeCast<JSAny?>(value)));
}

@JS('push')
external void push(JSObject properties, [bool runes, bool immutable]);

@JS('pop')
external void pop([JSObject? accessors]);
