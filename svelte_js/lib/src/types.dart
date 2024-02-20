@JS(r'$$')
library;

import 'dart:js_interop';

extension type FragmentFactory(JSFunction ref) {}

extension type Signal<V>(JSObject ref) {}

extension type SourceSignal<V>(JSObject ref) implements Signal<V> {}
