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
extension type Signal<T>(JSObject signal) implements MaybeSignal<T> {}

@optionalTypeArgs
extension type SourceSignal<T>(JSObject sourceSignal) implements Signal<T> {}

@optionalTypeArgs
extension type ComputationSignal<T>(JSObject computationSignal)
    implements Signal<T> {}

extension type EffectSignal(JSObject effectSignal)
    implements ComputationSignal<void Function()?> {}

@optionalTypeArgs
extension type MaybeSignal<T>(JSObject signalOrT) implements JSObject {}
