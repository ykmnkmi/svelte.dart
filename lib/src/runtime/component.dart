import 'dart:html';

import 'package:meta/dart2js.dart' show noInline;
import 'package:svelte/src/runtime/fragment.dart';
import 'package:svelte/src/runtime/lifecycle.dart';
import 'package:svelte/src/runtime/scheduler.dart';
import 'package:svelte/src/runtime/state.dart';

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

@noInline
void init(
  Component component,
  Options options, [
  Instance? instance,
  FragmentFactory? createFragment,
  void Function(Element)? appendStyles,
]) {
  var parentComponent = currentComponent;
  setCurrentComponent(component);

  var state = component._state
    ..fragment = null
    ..instance = <Object?>[]
    ..root = options.target ?? parentComponent?._state.root;

  var target = options.target;

  if (target != null && appendStyles != null) {
    appendStyles(target);
  }

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
void destroyComponent(Component component, bool detaching) {
  component._state
    ..fragment?.detach(detaching)
    ..fragment = null
    ..instance = <Object?>[];
}
