@JS(r'$$')
library;

import 'dart:js_interop';

import 'package:svelte_js/src/types.dart';

@JS('pre_effect')
external JSObject _preEffect(JSFunction function);

EffectSignal preEffect(void Function() function) {
  return EffectSignal(_preEffect(function.toJS));
}

@JS('render_effect')
external JSObject _renderEffect(JSFunction function);

EffectSignal renderEffect(void Function() function) {
  void callback(Block block, Signal signal) {
    function();
  }

  return EffectSignal(_renderEffect(callback.toJS));
}
