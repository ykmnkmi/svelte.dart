import 'dart:html';

import 'package:piko/runtime.dart';

abstract class Component<T extends Component<T>> {
  Fragment<T> render([Scheduler? scheduler]);
}

abstract class Fragment<T extends Component<T>> {
  Fragment(this.context, this.scheduler);

  final T context;

  final Scheduler scheduler;

  void create() {}

  void mount(Node target, [Node? anchor]) {}

  void update() {}

  void detach(bool detach) {}
}
