import 'dart:html';

import 'package:meta/dart2js.dart' show noInline;
import 'package:meta/meta.dart' show internal;
import 'package:svelte/src/runtime/fragment.dart';
import 'package:svelte/src/runtime/lifecycle.dart';
import 'package:svelte/src/runtime/scheduler.dart';

typedef Instance = List<Object?>;

typedef Invalidate = void Function(int index, Object? value);

// TODO(runtime): replace with records
class State {
  Fragment? fragment;

  late Instance instance;

  late int dirty;

  Element? root;
}

abstract class Component {
  @internal
  final State state = State();

  @internal
  bool destroyed = false;

  bool get isDestroyed {
    return destroyed;
  }

  void destroy() {
    if (destroyed) {
      return;
    }

    destroyComponent(this, true);
    destroyed = true;
  }
}

// TODO(runtime): replace with records
class Options {
  const Options([
    this.target,
    this.anchor,
    this.hydrate = false,
    this.intro = false,
  ]);

  final Element? target;

  final Node? anchor;

  final bool hydrate;

  final bool intro;
}

@noInline
void init<T extends Component>({
  required T component,
  required Options options,
  Instance Function(T component, Invalidate invalidate)? createInstance,
  Fragment Function(Instance instance)? createFragment,
  void Function(Element target)? appendStyles,
  int dirty = -1,
}) {
  var parentComponent = currentComponent;
  setCurrentComponent(component);

  var state = component.state
    // ..fragment = null
    ..instance = <Object?>[]
    ..dirty = dirty
    ..root = options.target ?? parentComponent?.state.root;

  var target = options.target;

  if (target != null && appendStyles != null) {
    appendStyles(target);
  }

  var ready = false;

  if (createInstance != null) {
    void invalidate(int index, Object? value) {
      if (state.instance[index] != (state.instance[index] = value)) {
        if (ready) {
          makeComponentDirty(component, index);
        }
      }
    }

    state.instance = createInstance(component, invalidate);
  }

  ready = true;

  if (createFragment != null) {
    state.fragment = createFragment(state.instance);
  }

  if (target != null) {
    if (options.hydrate) {
      // ...
    } else {
      state.fragment?.create();
    }

    if (options.intro) {
      // ...
    }

    mountComponent(component, target, options.anchor);
    flush();
  }

  setCurrentComponent(parentComponent);
}

@noInline
void createComponent(Component component) {
  component.state.fragment?.create();
}

@noInline
void mountComponent(Component component, Element target, [Node? anchor]) {
  component.state.fragment?.mount(target, anchor);
}

@noInline
void makeComponentDirty(Component component, int index) {
  if (component.state.dirty == -1) {
    dirtyComponents.add(component);
    scheduleUpdate();
    component.state.dirty = 0;
  }
}

@noInline
void updateComponent(Component component) {
  var state = component.state;
  var fragment = state.fragment;

  if (fragment != null) {
    var dirty = state.dirty;
    state.dirty = -1;
    fragment.update(state.instance, dirty);
  }
}

@noInline
void destroyComponent(Component component, bool detaching) {
  component.state
    ..fragment?.detach(detaching)
    ..fragment = null
    ..instance = <Object?>[];
}
