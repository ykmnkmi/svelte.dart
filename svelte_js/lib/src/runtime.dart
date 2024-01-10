@JS(r'$$')
library;

import 'package:js/js.dart';
import 'package:svelte_js/src/types.dart';

@JS('get')
external V get<V>(Signal<V> signal);

@JS('set')
external V set<V>(Signal<V> signal, V value);

@JS('mutable_source')
external SourceSignal<V> mutableSource<V>(V value);

@JS('push')
external void push(Object properties, [bool runes, bool immutable]);

@JS('pop')
external void pop([Object? accessors]);
