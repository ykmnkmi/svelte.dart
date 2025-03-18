import 'dart:js_interop';

import 'package:meta/dart2js.dart';
import 'package:svelte_runtime/src/unsafe_cast.dart';
import 'package:web/web.dart';

extension ValueReference on HTMLElement {
  @JS('__value')
  external ExternalDartReference<Object?> valueReference;

  // ignore: non_constant_identifier_names
  Object? get value__ {
    // ignore: unnecessary_this
    return this.valueReference.toDartObject;
  }

  // ignore: non_constant_identifier_names
  set value__(Object? value) {
    // ignore: unnecessary_this
    this.valueReference = value.toExternalReference;
  }
}

@noInline
void setElementValue(HTMLElement input, Object? value) {
  unsafeCast<HTMLInputElement>(input)
    ..value__ = value
    ..value = '${value ?? ''}';
}
