import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:piko/dom.dart';

import 'package:piko/src/runtime/fragment.dart';
import 'package:piko/src/runtime/scheduler.dart';

abstract class Component<T extends Object> {
  Component(this.state);

  @internal
  @nonVirtual
  final T state;

  Fragment get fragment;

  // TODO: use bitmask
  @internal
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
  component.fragment.create();
}

void mountComponent(Component component, Element target, [Node? anchor]) {
  component.fragment.mount(target, anchor);
  addRenderCallback(component.onMount);
  addRenderCallback(component.beforeUpdate);
}

void detachComponent(Component component, bool detaching) {
  component.onDestroy();
  component.fragment.detach(detaching);
}
