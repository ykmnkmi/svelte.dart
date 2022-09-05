import 'dart:collection';

import 'package:meta/dart2js.dart';
import 'package:meta/meta.dart';
import 'package:piko/dom.dart';
import 'package:piko/src/runtime/fragment.dart';
import 'package:piko/src/runtime/scheduler.dart';

@optionalTypeArgs
abstract class Context {
  Component get component;

  @internal
  @noInline
  void update(Set<String> dirty) {}
}

abstract class Component {
  // TODO: use bitmask
  @internal
  @nonVirtual
  Set<String> dirty = HashSet<String>();

  Context get context;

  Fragment get fragment;

  @internal
  @noInline
  @nonVirtual
  void markDirty(String name) {
    if (dirty.isEmpty) {
      scheduleUpdateFor(this);
    }

    dirty.add(name);
  }

  @internal
  @noInline
  @nonVirtual
  void invalidate(String name, Object? oldValue, Object? newValue) {
    if (identical(oldValue, newValue)) {
      return;
    }

    markDirty(name);
  }
}

@noInline
void createComponent(Component component) {
  component.fragment.create();
}

@noInline
void mountComponent(Component component, Element target, Node? anchor) {
  component.fragment.mount(target, anchor);
}

@noInline
void detachComponent(Component component, bool detaching) {
  component.fragment.detach(detaching);
}
