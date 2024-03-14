@JS(r'$$')
library;

import 'dart:js_interop';

import 'package:svelte_js/src/wasm/boxing.dart';

@JS('set_getter')
external JSVoid _setGetter(JSObject object, JSString key, JSFunction getter);

void setGetter<T>(JSObject object, String key, T Function() getter) {
  JSAny? jsGetter() {
    return box(getter());
  }

  _setGetter(object, key.toJS, jsGetter.toJS);
}
