@JS(r'$$')
library;

import 'dart:js_interop';

import 'package:meta/meta.dart';
import 'package:web/web.dart';

extension type Template(JSFunction _) implements JSFunction {}

extension type Fragment(JSFunction _) implements JSFunction {}

extension type Block(JSObject _) implements JSObject {}

@optionalTypeArgs
extension type Signal<T>(JSObject _) implements MaybeSignal<T> {}

@optionalTypeArgs
extension type SourceSignal<T>(JSObject _) implements Signal<T> {}

@optionalTypeArgs
extension type ComputationSignal<T>(JSObject _) implements Signal<T> {}

extension type EffectSignal(JSObject _)
    implements ComputationSignal<void Function()?> {}

@optionalTypeArgs
extension type MaybeSignal<T>(JSObject _) implements JSObject {}

@optionalTypeArgs
typedef Component<T extends JSObject> = void Function(
    Node anchor, T properties);

extension type ComponentReference(JSObject _) implements JSObject {}
