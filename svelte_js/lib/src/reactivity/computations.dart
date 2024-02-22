@JS(r'$$')
library;

import 'dart:js_interop';

import 'package:svelte_js/src/types.dart';

@JS('pre_ffect')
external JSObject _preEffect(JSFunction function);

EffectSignal preEffect(void Function() function) {
  return EffectSignal(_preEffect(function.toJS));
}
