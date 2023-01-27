import 'dart:html' show Element, Node;

import 'package:meta/meta.dart' show protected;
import 'package:svelte/src/runtime/fragment.dart';
import 'package:svelte/src/runtime/lifecycle.dart';
import 'package:svelte/src/runtime/state.dart';

abstract class Component {
  @protected
  late final State state;
}

void init(
  Component component,
  Element? target,
  Node? anchor,
  Instance? instance,
  FragmentFactory? createFragment,
) {
  var parentComponent = currentComponent;
  setCurrentComponent(component);

  var state = component.state = State(
    fragment: null,
    instance: <Object?>[],
  );

  if (createFragment != null) {
    state.fragment = createFragment(state.instance);
  }

  if (target != null) {
    state.fragment?.create();
    mountComponent(component, target, anchor);
  }

  setCurrentComponent(parentComponent);
}

void createComponent(Component component) {
  component.state.fragment?.create();
}

void mountComponent(Component component, Element target, [Node? anchor]) {
  component.state.fragment?.mount(target, anchor);
}

void destroyComponent(Component component, bool detaching) {
  component.state.fragment?.detach(detaching);
}
