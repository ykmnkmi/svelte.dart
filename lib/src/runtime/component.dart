part of piko.runtime;

class Context {
  Context(this.root) : scheduler = Scheduler();

  final Element root;

  final Scheduler scheduler;
}

abstract class Component {
  @internal
  late Fragment<Component> fragment;

  Fragment<Component> createFragment(Context tree);
}

abstract class Fragment<T extends Component> {
  Fragment(this.context, this.component, {this.depth = 0}) : dirty = <String>{} {
    component.fragment = this;
  }

  final Context context;

  final T component;

  final int depth;

  final Set<String> dirty;

  Scheduler get scheduler {
    return context.scheduler;
  }

  void create() {}

  void mount(Element target, [Node? anchor]) {}

  void makeDirty(String aspect) {
    if (dirty.isEmpty) {
      scheduler.scheduleUpdate(this);
    }

    dirty.add(aspect);
  }

  void update(Set<String> aspects) {}

  void detach([bool detaching = true]) {}
}

void createFragment<T extends Component>(Fragment<T> fragment) {
  fragment.create();
}

void mountFragment<T extends Component>(Fragment<T> fragment, Element target, [Node? anchor]) {
  fragment.mount(target, anchor);
}

void destroyFragment<T extends Component>(Fragment<T> fragment) {
  fragment.detach();
}
