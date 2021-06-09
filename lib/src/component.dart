part of '../piko.dart';

class RenderTree {
  RenderTree(this.root) : scheduler = Scheduler();

  final Scheduler scheduler;

  final Element root;
}

abstract class Component<T extends Component<T>> {
  Fragment<T> render(RenderTree tree);
}

abstract class Fragment<T extends Component<T>> {
  Fragment(this.context, this.tree) : dirty = <String>{};

  final RenderTree tree;

  final T context;

  final Set<String> dirty;

  Scheduler get scheduler {
    return tree.scheduler;
  }

  void create() {}

  void mount(Element target, [Node? anchor]) {}

  void markDirty(String aspect) {
    dirty.add(aspect);
    scheduler.scheduleUpdate(this);
  }

  void update(Set<String> aspects) {}

  void detach([bool detach = false]) {}
}
