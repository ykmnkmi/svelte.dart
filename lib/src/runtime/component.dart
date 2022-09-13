import 'dart:collection';

import 'package:piko/dom.dart';

import 'package:piko/src/runtime/fragment.dart';
import 'package:piko/src/runtime/scheduler.dart';
import 'package:piko/src/runtime/stateful.dart';

abstract class Component {
  Fragment get fragment;

  void onMount() {}

  void afterChanges() {}

  void onDestroy() {}
}

void createComponent(Component component) {
  component.fragment.create();
}

void mountComponent(Component component, Element target, [Node? anchor]) {
  component.fragment.mount(target, anchor);
  addRenderCallback(component.onMount);

  if (component is StatefulComponent) {
    addRenderCallback(component.beforeUpdate);
  }
}

void detachComponent(Component component, bool detaching) {
  component.onDestroy();
  component.fragment.detach(detaching);

  if (component is StatefulComponent) {
    component.context = HashMap<String, Object>();
  }
}
