import 'dart:collection';
import 'dart:html';

import 'package:piko/runtime.dart';

abstract class Component<T> {
  Fragment<T> fragment;

  Fragment<T> render();
}

abstract class Fragment<T> {
  static int nextId = 0;

  Fragment(this.context)
      : id = nextId++,
        dirty = HashSet<String>();

  final int id;

  final T context;

  final Set<String> dirty;

  Scheduler scheduler;

  void create() {}

  void mount(Element target) {}

  void update([Set<String> aspects = const {}]) {}

  void detach(bool removing) {}
}
