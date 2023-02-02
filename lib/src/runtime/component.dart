import 'dart:html';

import 'package:svelte/src/runtime/fragment.dart';
import 'package:svelte/src/runtime/lifecycle.dart';
import 'package:svelte/src/runtime/options.dart';
import 'package:svelte/src/runtime/scheduler.dart';
import 'package:svelte/src/runtime/state.dart';
import 'package:svelte/src/runtime/transition.dart';
import 'package:svelte/src/runtime/utilities.dart';

typedef Invalidate = void Function(int index, Object? value);

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

typedef UpdateFactory = void Function() Function(List<int> dirty);

void setComponentUpdate(Component component, UpdateFactory callback) {
  component._state.update = callback(component._state.dirty);
}

void init<T extends Component>({
  required T component,
  required Options options,
  List<Object?> Function(T component, Invalidate invalidate)? createInstance,
  Fragment Function(List<Object?> instance)? createFragment,
  void Function(Element target)? appendStyles,
  List<int>? dirty,
}) {
  var parentComponent = currentComponent;
  setCurrentComponent(component);

  var state = component._state
    ..fragment = null
    ..instance = <Object?>[]
    ..update = noop
    ..dirty = dirty ?? <int>[-1]
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
  var dirty = component._state.dirty;

  if (dirty[0] == -1) {
    dirtyComponents.add(component);
    scheduleUpdate();
    dirty.fillRange(0, dirty.length, 0);
  }

  dirty[(index ~/ 31)] |= 1 << index % 31;
}

void updateComponent(Component component) {
  var state = component._state;
  state.update();

  var fragment = state.fragment;

  if (fragment != null) {
    var dirty = state.dirty;
    state.dirty[0] = -1;
    fragment.update(state.instance, dirty);
  }
}

void transitionInComponent(Component component, bool local) {
  transitionIn(component._state.fragment, local);
}

void transitionOutComponent(
  Component component,
  bool local, [
  void Function()? callback,
]) {
  transitionOut(component._state.fragment, local, callback);
}

void destroyComponent(Component component, bool detaching) {
  component._state
    ..fragment?.detach(detaching)
    ..fragment = null
    ..instance = <Object?>[];
}
