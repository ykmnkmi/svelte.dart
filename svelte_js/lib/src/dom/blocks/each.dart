@JS(r'$$')
library;

import 'dart:js_interop';

import 'package:svelte_js/src/types.dart';
import 'package:web/web.dart';

extension on JSArray {
  external void operator []=(int index, JSBoxedDartObject? value);
}

@JS('each_indexed')
external void _eachIndexed(Node anchor, JSFunction collection, JSNumber flags,
    JSFunction render, JSFunction? fallback);

void eachIndexed<T>(
    Node anchor,
    List<T> Function() collection,
    int flags,
    void Function(Node? $anchort, Signal<T> $item, int index) render,
    void Function(Node $anchor)? fallback) {
  JSArray collectionWrapper() {
    var list = collection();
    var length = list.length;

    var array = JSArray.withLength(length);

    for (var index = 0; index < length; index += 1) {
      array[index] = list[index]?.toJSBox;
    }

    return array;
  }

  void renderWrapper(Node? anchor, JSObject item, JSNumber index) {
    render(anchor, item as Signal<T>, index.toDartInt);
  }

  _eachIndexed(anchor, collectionWrapper.toJS, flags.toJS, renderWrapper.toJS,
      fallback?.toJS);
}
