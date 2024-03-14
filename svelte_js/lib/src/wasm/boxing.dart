import 'dart:js_interop';

T unbox<T>(JSAny? value) {
  if (value is JSBoxedDartObject) {
    return value.toDart as T;
  }

  return value as T;
}

JSAny? box(Object? value) {
  if (value is JSAny?) {
    return value;
  }

  return value.toJSBox;
}
