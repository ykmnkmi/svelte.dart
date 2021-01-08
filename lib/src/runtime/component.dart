import 'dart:collection';
import 'dart:html';

import 'package:piko/runtime.dart';

abstract class Component<T> {
  Fragment<T> render();
}

abstract class Fragment<T> {
  Fragment(this.context) : dirty = HashSet<String>();

  final T context;

  final Set<String> dirty;

  Scheduler scheduler;

  void create() {}

  void mount(Element target) {}

  void update([Set<String> aspects = const <String>{}]) {}

  void detach(bool removing) {}
}
