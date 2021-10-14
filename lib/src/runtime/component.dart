import 'package:meta/meta.dart';
import 'package:piko/dom.dart';

import 'scheduler.dart';

class RenderTree {
  RenderTree(this.root) : scheduler = Scheduler();

  final Scheduler scheduler;

  final Element root;
}

abstract class Component<T extends Component<T>> {
  @internal
  late Fragment<T> fragment;

  Fragment<T> render(RenderTree tree);
}

abstract class Fragment<T extends Component<T>> {
  Fragment(this.context, this.tree) : dirty = <String>{} {
    context.fragment = this;
  }

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

  void detach([bool detach = true]) {}
}

void createFragment<T extends Component<T>>(Fragment<T> fragment) {
  fragment.create();
}

void mountFragment<T extends Component<T>>(Fragment<T> fragment, Element target, [Node? anchor]) {
  fragment.mount(target, anchor);
}

void detachFragment<T extends Component<T>>(Fragment<T> fragment) {
  fragment.detach();
}
