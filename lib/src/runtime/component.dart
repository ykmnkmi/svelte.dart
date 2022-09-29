import 'dart:collection';
import 'dart:html';

import 'package:meta/meta.dart';

import 'package:nutty/src/runtime/fragment.dart';
import 'package:nutty/src/runtime/scheduler.dart';

abstract class Component<T extends Object> {
  Component(this.context);

  // TODO: use list
  @internal
  @nonVirtual
  T context;

  @internal
  Fragment get fragment;

  // TODO: use bitmask
  @internal
  @nonVirtual
  Set<String> dirty = HashSet<String>();

  @internal
  @nonVirtual
  void markDirty(String name) {
    if (dirty.isEmpty) {
      scheduleUpdateFor(this);
    }

    dirty.add(name);
  }

  // TODO: use bitmask
  @internal
  @nonVirtual
  void invalidate(String name, Object? oldValue, Object? newValue) {
    if (identical(oldValue, newValue)) {
      return;
    }

    markDirty(name);
  }

  void afterChanges() {}

  void onMount() {}

  void beforeUpdate() {}

  void afterUpdate() {}

  void onDestroy() {}
}

void createComponent(Component component) {
  component.afterChanges();
  component.beforeUpdate();
  component.fragment.create();
}

void mountComponent(Component component, Element target, [Node? anchor]) {
  component.fragment.mount(target, anchor);
  addRenderCallback(component.onMount);
  addRenderCallback(component.afterUpdate);
}

void destroyComponent(Component component, bool detaching) {
  component.onDestroy();
  component.fragment.detach(detaching);
}
