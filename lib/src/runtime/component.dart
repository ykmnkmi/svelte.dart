import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:piko/dom.dart';
import 'package:piko/src/runtime/fragment.dart';
import 'package:piko/src/runtime/scheduler.dart';

@optionalTypeArgs
abstract class Context {
  Component get component;

  @internal
  void set() {}

  @internal
  void update(Set<String> dirty) {}
}

abstract class Component {
  @internal
  @nonVirtual
  Set<String> dirty = HashSet<String>();

  Context get context;

  Fragment get fragment;

  @internal
  @nonVirtual
  void markDirty(String name) {
    if (dirty.isEmpty) {
      scheduleUpdateFor(this);
    }

    dirty.add(name);
  }

  @internal
  @nonVirtual
  void invalidate(String name, Object? oldValue, Object? newValue) {
    if (identical(oldValue, newValue)) {
      return;
    }

    markDirty(name);
  }
}

@internal
void createComponent(Component component) {
  component.fragment.create();
}

@internal
void mountComponent(Component component, Element target, Node? anchor) {
  component.fragment.mount(target, anchor);
}

@internal
void detachComponent(Component component, bool detaching) {
  component.fragment.detach(detaching);
}
