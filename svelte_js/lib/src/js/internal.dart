@JS(r'$$')
library;

import 'dart:js_interop';

import 'package:svelte_js/src/js/unsafe_cast.dart';

@JS('set_getter')
external JSVoid _setGetter(JSObject object, JSString key, JSFunction getter);

void setGetter<T>(JSObject object, String key, T Function() getter) {
  var jsGetter = unsafeCast<JSAny? Function()>(getter);
  _setGetter(object, key.toJS, jsGetter.toJS);
}
