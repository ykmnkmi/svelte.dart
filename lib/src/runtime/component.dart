import 'dart:html';

import 'package:meta/dart2js.dart' show noInline;
import 'package:meta/meta.dart' show internal;
import 'package:svelte/src/runtime/fragment.dart';
import 'package:svelte/src/runtime/lifecycle.dart';
import 'package:svelte/src/runtime/scheduler.dart';
import 'package:svelte/src/runtime/state.dart';

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
void init<T extends Component>(
  T component,
  Options options, [
  InstanceFactory<T>? instance,
  FragmentFactory? createFragment,
  void Function(Element)? appendStyles,
]) {
  var parentComponent = currentComponent;
  setCurrentComponent(component);

  var state = component.state
    // ..fragment = null
    // ..instance = <Object?>[]
    ..root = options.target ?? parentComponent?.state.root;

  var target = options.target;

  if (target != null && appendStyles != null) {
    appendStyles(target);
  }

  if (instance != null) {
    state.instance = instance(component);
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
  component.state.fragment?.create();
}

@noInline
void mountComponent(Component component, Element target, [Node? anchor]) {
  component.state.fragment?.mount(target, anchor);
}

@noInline
void destroyComponent(Component component, bool detaching) {
  component.state
    ..fragment?.detach(detaching)
    ..fragment = null
    ..instance = <Object?>[];
}
