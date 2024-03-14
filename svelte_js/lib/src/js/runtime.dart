@JS(r'$$')
library;

import 'dart:js_interop';

import 'package:svelte_js/src/js/unsafe_cast.dart';
import 'package:svelte_js/src/types.dart';

@JS('get')
external JSAny? _get(JSObject signal);

T get<T>(Signal<T> signal) {
  return unsafeCast<T>(_get(signal));
}

@JS('set')
external JSAny? _set(JSObject signal, JSAny? value);

T set<T>(Signal<T> signal, T? value) {
  var jsValue = unsafeCast<JSAny?>(value);
  return unsafeCast<T>(_set(signal, jsValue));
}

@JS('mutate')
external JSAny? _mutate(JSObject signal, JSAny? value);

T mutate<T>(Signal<T> signal, T value) {
  var jsValue = unsafeCast<JSAny?>(value);
  return unsafeCast<T>(_mutate(signal, jsValue));
}

@JS('untrack')
external JSAny? _untrack(JSFunction function);

T untrack<T>(T Function() function) {
  var jsFunction = unsafeCast<JSAny? Function()>(function);
  return unsafeCast<T>(_untrack(jsFunction.toJS));
}

@JS('push')
external void push<T extends JSObject>(T properties, [bool? runes]);

@JS('pop')
external void pop<T extends JSObject>([T? component]);

@JS('unwrap')
external JSAny? _unwrap(JSAny? value);

T unwrap<T>(MaybeSignal<T>? value) {
  var jsValue = unsafeCast<JSAny?>(value);
  return unsafeCast<T>(_unwrap(jsValue));
}
