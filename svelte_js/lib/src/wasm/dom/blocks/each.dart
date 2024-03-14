@JS(r'$$')
library;

import 'dart:js_interop';

import 'package:svelte_js/src/types.dart';
import 'package:svelte_js/src/wasm/boxing.dart';
import 'package:web/web.dart';

extension on JSArray {
  external void operator []=(int index, JSAny? value);
}

@JS('each_keyed')
external void _eachKeyed(
  Node anchor,
  JSFunction collection,
  JSNumber flags,
  JSFunction? key,
  JSFunction render,
  JSFunction? fallback,
);

void eachKeyed<T extends Object?>(
  Node anchor,
  List<T> Function() collection,
  int flags,
  Object Function(T item, int index, List<T> list)? key,
  void Function(
    Node? anchor,
    MaybeSignal<T> item,
    MaybeSignal<int> index,
  ) render,
  void Function(Node $anchor)? fallback,
) {
  JSArray jsCollection() {
    var list = collection();
    var length = list.length;

    var array = JSArray.withLength(length);

    for (var index = 0; index < length; index += 1) {
      array[index] = box(list[index]);
    }

    return array;
  }

  JSAny? Function(JSAny? item, JSNumber index, JSArray list)? jsKey;

  if (key != null) {
    jsKey = (JSAny? item, JSNumber index, JSArray list) {
      return box(key(
        unbox<T>(item),
        index.toDartInt,
        list.toDart.map<T>(unbox<T>).toList(),
      ));
    };
  }

  void jsRender(Node? anchor, JSObject item, JSObject index) {
    render(anchor, MaybeSignal<T>(item), MaybeSignal<int>(index));
  }

  _eachKeyed(
    anchor,
    jsCollection.toJS,
    flags.toJS,
    jsKey?.toJS,
    jsRender.toJS,
    fallback?.toJS,
  );
}

@JS('each_indexed')
external void _eachIndexed(
  Node anchor,
  JSFunction collection,
  JSNumber flags,
  JSFunction render,
  JSFunction? fallback,
);

void eachIndexed<T>(
  Node anchor,
  List<T> Function() collection,
  int flags,
  void Function(
    Node? anchor,
    MaybeSignal<T> item,
    int index,
  ) render,
  void Function(Node $anchor)? fallback,
) {
  JSArray jsCollection() {
    var list = collection();
    var length = list.length;

    var array = JSArray.withLength(length);

    for (var index = 0; index < length; index += 1) {
      array[index] = box(list[index]);
    }

    return array;
  }

  void jsRender(Node? anchor, JSObject item, JSNumber index) {
    render(anchor, MaybeSignal<T>(item), index.toDartInt);
  }

  _eachIndexed(
    anchor,
    jsCollection.toJS,
    flags.toJS,
    jsRender.toJS,
    fallback?.toJS,
  );
}
