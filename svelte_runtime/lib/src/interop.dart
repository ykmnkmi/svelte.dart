import 'dart:js_interop';

extension type PropertyDescriptor._(JSObject _) implements JSObject {
  external factory PropertyDescriptor({bool configurable, JSFunction get});
}

@JS('Object.defineProperty')
external PropertyDescriptor defineProperty(
  JSObject object,
  String property,
  PropertyDescriptor descriptor,
);
