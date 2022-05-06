import 'package:meta/meta.dart';
import 'package:piko/dom.dart';
import 'package:piko/src/runtime/scheduler.dart';

class RenderTree {
  RenderTree() : scheduler = Scheduler();

  final Scheduler scheduler;
}

abstract class Component<T extends Component<T>> {
  @internal
  late Fragment<T> fragment;

  Fragment<T> createFragment(RenderTree tree);
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
    if (dirty.contains(aspect)) {
      return;
    }

    dirty.add(aspect);
    scheduler.scheduleUpdate(this);
  }

  void update(Set<String> aspects) {}

  void destroy([bool detaching = true]) {}
}

void createFragment<T extends Component<T>>(Fragment<T> fragment) {
  fragment.create();
}

void mountFragment<T extends Component<T>>(Fragment<T> fragment, Element target, [Node? anchor]) {
  fragment.mount(target, anchor);
}

void destryFragment<T extends Component<T>>(Fragment<T> fragment) {
  fragment.destroy();
}
