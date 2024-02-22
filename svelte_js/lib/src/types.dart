@JS(r'$$')
library;

import 'dart:js_interop';

import 'package:web/web.dart';

extension type TemplateFactory(JSFunction ref) {}

typedef ComponentFactory = void Function(Node anchor, JSObject properties);

extension type Signal<V>(JSObject ref) {}

extension type SourceSignal<V>(JSObject ref) implements Signal<V> {}

extension type ComputationSignal<V>(JSObject ref) implements Signal<V> {}

extension type EffectSignal(JSObject ref)
    implements ComputationSignal<void Function()?> {}
