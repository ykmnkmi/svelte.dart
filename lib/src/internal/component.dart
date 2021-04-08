import 'dart:html';

import 'package:piko/internal.dart';

abstract class Component<T extends Component<T>> {
  Fragment<T> render([Scheduler? scheduler]);
}

abstract class Fragment<T extends Component<T>> {
  static int nextId = 0;

  Fragment(this.context, this.scheduler) : id = nextId++;

  final int id;

  final T context;

  final Scheduler scheduler;

  void create() {}

  void mount(Node target, [Node? anchor]) {}

  void update() {}

  void detach(bool detach) {}
}
