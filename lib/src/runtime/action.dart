import 'dart:html' show Node;

import 'package:meta/meta.dart';

@optionalTypeArgs
abstract class Action<T extends Node, P> {
  Action(this.node);

  final T node;

  void update(P parameter) {}

  void destroy() {}
}
