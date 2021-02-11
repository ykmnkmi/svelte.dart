// @dart=2.10

import 'dart:collection';
import 'dart:html';

import 'package:piko/runtime.dart';

abstract class Component<T extends Component<T>> {
  Fragment<T> _fragment;

  Fragment<T> get fragment => _fragment;

  Fragment<T> render();
}

abstract class Fragment<T extends Component<T>> {
  static int nextId = 0;

  Fragment(this.context)
      : id = nextId++,
        dirty = HashSet<String>() {
    context._fragment = this;
  }

  final int id;

  final T context;

  final Set<String> dirty;

  Scheduler scheduler;

  void create() {}

  void mount(Element target) {}

  void update([Set<String> aspects = const {}]) {}

  void detach(bool detach) {}
}
