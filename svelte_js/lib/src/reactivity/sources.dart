@JS(r'$$')
library;

import 'dart:js_interop';

import 'package:svelte_js/src/types.dart';

@JS('mutable_source')
external JSObject _mutableSource(JSBoxedDartObject? value);

SourceSignal<V> mutableSource<V>([V? value]) {
  return SourceSignal<V>(_mutableSource(value?.toJSBox));
}
