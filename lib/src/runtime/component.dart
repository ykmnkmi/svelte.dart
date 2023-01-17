import 'dart:collection';
import 'dart:html';

import 'package:svelte/src/runtime/fragment.dart';
import 'package:svelte/src/runtime/scheduler.dart';

abstract class Component {
  Fragment get fragment;

  // TODO: use bitmask
  Set<String> dirty = HashSet<String>();

  void markDirty(String name) {
    if (dirty.isEmpty) {
      scheduleUpdateFor(this);
    }

    dirty.add(name);
  }

  // TODO: use bitmask
  void invalidate(String name, Object? oldValue, Object? newValue) {
    if (identical(oldValue, newValue)) {
      return;
    }

    markDirty(name);
  }

  void onChanges() {}

  void onMount() {}

  void beforeUpdate() {}

  void afterUpdate() {}

  void onDestroy() {}
}

void createComponent(Component component) {
  component
    ..onChanges()
    ..beforeUpdate()
    ..fragment.create();
}

void mountComponent(Component component, Element target, [Node? anchor]) {
  component.fragment.mount(target, anchor);
  addRenderCallback(component.onMount);
  addRenderCallback(component.afterUpdate);
}

void destroyComponent(Component component, bool detaching) {
  component
    ..onDestroy()
    ..fragment.detach(detaching);
}
