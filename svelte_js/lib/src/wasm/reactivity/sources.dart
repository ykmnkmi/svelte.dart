@JS(r'$$')
library;

import 'dart:js_interop';

import 'package:svelte_js/src/types.dart';
import 'package:svelte_js/src/wasm/boxing.dart';

@JS('mutable_source')
external JSObject _mutableSource(JSAny? value);

SourceSignal<V> mutableSource<V>([V? value]) {
  return SourceSignal<V>(_mutableSource(box(value)));
}
