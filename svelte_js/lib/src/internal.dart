@JS(r'$$')
library;

import 'dart:js_interop';

@JS('set_getter')
external JSVoid _setGetter(JSObject object, JSString key, JSFunction getter);

void setGetter<T>(JSObject object, String key, T Function() getter) {
  _setGetter(object, key.toJS, getter.toJS);
}
