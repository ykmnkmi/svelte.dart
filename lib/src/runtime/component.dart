import 'dart:html';

import 'package:meta/dart2js.dart';
import 'package:svelte/src/runtime/fragment.dart';
import 'package:svelte/src/runtime/lifecycle.dart';
import 'package:svelte/src/runtime/options.dart';
import 'package:svelte/src/runtime/scheduler.dart';
import 'package:svelte/src/runtime/state.dart';
import 'package:svelte/src/runtime/transition.dart';
import 'package:svelte/src/runtime/utilities.dart';

typedef Invalidate = void Function(int i, Object? value);

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

@noInline
void setComponentUpdate(Component component, UpdateFactory updateFactory) {
  component._state.update = updateFactory(component._state.dirty);
}

@noInline
void init<T extends Component>({
  required T component,
  required Options options,
  List<Object?> Function(T component, Invalidate invalidate)? createInstance,
  Fragment Function(List<Object?> instance)? createFragment,
  void Function(Element? target)? appendStyles,
  List<int>? dirty,
}) {
  var parentComponent = currentComponent;
  setCurrentComponent(component);

  var target = options.target;

  var state = component._state
    ..fragment = null
    ..instance = <Object?>[]
    ..update = noop
    ..dirty = dirty ?? <int>[-1]
    ..root = target ?? parentComponent?._state.root;

  if (appendStyles != null) {
    appendStyles(target);
  }

  var ready = false;

  if (createInstance != null) {
    void invalidate(int i, Object? value) {
      if (state.instance[i] != (state.instance[i] = value)) {
        if (ready) {
          makeComponentDirty(component, i);
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

@noInline
void createComponent(Component component) {
  component._state.fragment?.create();
}

@noInline
void mountComponent(Component component, Element target, [Node? anchor]) {
  component._state.fragment?.mount(target, anchor);
}

@noInline
void makeComponentDirty(Component component, int i) {
  var dirty = component._state.dirty;

  if (dirty[0] == -1) {
    dirtyComponents.add(component);
    scheduleUpdate();
    dirty.fillRange(0, dirty.length, 0);
  }

  dirty[(i ~/ 31)] |= 1 << i % 31;
}

@noInline
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

@noInline
void transitionInComponent(Component component, bool local) {
  transitionIn(component._state.fragment, local);
}

@noInline
void transitionOutComponent(
  Component component,
  bool local, [
  void Function()? callback,
]) {
  transitionOut(component._state.fragment, local, callback);
}

@noInline
void destroyComponent(Component component, bool detaching) {
  component._state
    ..fragment?.detach(detaching)
    ..fragment = null
    ..instance = <Object?>[];
}
