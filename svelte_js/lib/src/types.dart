@JS(r'$$')
library;

import 'dart:js_interop';

import 'package:meta/meta.dart';

extension type TemplateFactory(JSFunction templateFactory)
    implements JSFunction {}

extension type FragmentFactory(JSFunction fragmentFactory)
    implements JSFunction {}

extension type Block(JSObject block) implements JSObject {}

@optionalTypeArgs
extension type Signal<V>(JSObject signal) implements JSObject {}

@optionalTypeArgs
extension type SourceSignal<V>(JSObject sourceSignal) implements Signal<V> {}

@optionalTypeArgs
extension type ComputationSignal<V>(JSObject computationSignal)
    implements Signal<V> {}

extension type EffectSignal(JSObject effectSignal)
    implements ComputationSignal<void Function()?> {}
