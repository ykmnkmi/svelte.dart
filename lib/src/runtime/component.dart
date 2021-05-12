import 'dart:html';

import 'scheduler.dart';

class RenderTree {
  RenderTree(this.root) : scheduler = Scheduler();

  final Scheduler scheduler;

  final Element root;
}

abstract class Component<T extends Component<T>> {
  Fragment<T> render(RenderTree tree);
}

abstract class Fragment<T extends Component<T>> {
  Fragment(this.context, this.tree);

  final T context;

  final RenderTree tree;

  void create() {}

  void mount(Element target, [Node? anchor]) {}

  void update() {}

  void detach(bool detach) {}
}
