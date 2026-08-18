import 'dart:js_interop';

import 'package:meta/meta.dart';
import 'package:svelte_runtime/src/unsafe_cast.dart';
import 'package:web/web.dart';

extension ValueReference on HTMLElement {
  @JS('__value')
  external ExternalDartReference<Object?> valueReference;

  @internal
  Object? get internalValue {
    // ignore: unnecessary_this
    return this.valueReference.toDartObject;
  }

  @internal
  set internalValue(Object? value) {
    // ignore: unnecessary_this
    this.valueReference = value.toExternalReference;
  }
}

void setElementValue(HTMLElement input, Object? value) {
  unsafeCast<HTMLInputElement>(input)
    ..internalValue = value
    ..value = '${value ?? ''}';
}
