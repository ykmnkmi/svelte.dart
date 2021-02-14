import 'dart:html';

import 'package:piko/runtime.dart';

abstract class Component<T extends Component<T>> {
  Fragment<T> render([Scheduler? scheduler]);
}

abstract class Fragment<T extends Component<T>> {
  static int nextId = 0;

  Fragment(this.context, this.scheduler)
      : id = nextId++;

  final int id;

  final T context;

  final Scheduler scheduler;

  void create() {}

  void mount(Node target) {}

  void update() {}

  void detach(bool detach) {}
}
