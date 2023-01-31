import 'dart:html';

import 'package:svelte/src/runtime/fragment.dart';
import 'package:svelte/src/runtime/lifecycle.dart';
import 'package:svelte/src/runtime/scheduler.dart';
import 'package:svelte/src/runtime/transition.dart';
import 'package:svelte/src/runtime/utilities.dart';

typedef Instance = List<Object?>;

typedef Invalidate = void Function(int index, Object? value);

// TODO(runtime): replace with records
class State {
  Fragment? fragment;

  late Instance instance;

  late VoidCallback update;

  late int dirty;

  Element? root;
}

abstract class Component {
  final State _state = State();

  bool _destroyed = false;

  bool get isDestroyed {
    return _destroyed;
  }

  void destroy() {
    if (_destroyed) {
      return;
    }

    destroyComponent(this, true);
    _destroyed = true;
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

  var state = component._state
    // ..fragment = null
    ..instance = <Object?>[]
    ..update = noop
    ..dirty = dirty
    ..root = options.target ?? parentComponent?._state.root;

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

  state.update();
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

void createComponent(Component component) {
  component._state.fragment?.create();
}

void mountComponent(Component component, Element target, [Node? anchor]) {
  component._state.fragment?.mount(target, anchor);
}

void makeComponentDirty(Component component, int index) {
  if (component._state.dirty == -1) {
    dirtyComponents.add(component);
    scheduleUpdate();
    component._state.dirty = 0;
  }

  component._state.dirty |= 1 << index;
}

void updateComponent(Component component) {
  var state = component._state;
  var fragment = state.fragment;

  if (fragment != null) {
    var dirty = state.dirty;
    state.dirty = -1;
    fragment.update(state.instance, dirty);
  }
}

void transitionInComponent(Component component, bool local) {
  var fragment = component._state.fragment;
  transitionIn(fragment, local);
}

void transitionOutComponent(
  Component component,
  bool local, [
  VoidCallback? callback,
]) {
  transitionOutComponent(component, local, callback);
}

void destroyComponent(Component component, bool detaching) {
  component._state
    ..fragment?.detach(detaching)
    ..fragment = null
    ..instance = <Object?>[];
}
