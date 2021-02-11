import 'dart:html';

import 'package:meta/meta.dart';
import 'package:piko/runtime.dart';

abstract class Component<T extends Component<T>> {
  @protected
  late Fragment<T> fragment;

  Fragment<T> render();
}

abstract class Fragment<T extends Component<T>> {
  static int nextId = 0;

  Fragment(this.context)
      : id = nextId++,
        dirty = <String>[] {
    context.fragment = this;
  }

  final int id;

  final T context;

  final List<String> dirty;

  late Scheduler scheduler;

  void create() {}

  void mount(Node target) {}

  void update([List<String> aspects = const <String>[]]) {}

  void detach(bool detach) {}
}
