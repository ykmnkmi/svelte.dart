import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:piko/dom.dart';
import 'package:piko/src/runtime/fragment.dart';
import 'package:piko/src/runtime/scheduler.dart';

abstract class Context {
  Context(this.component);

  final Component component;

  void update(Set<String> dirty) {}
}

abstract class Component {
  @internal
  final StreamController<CustomEvent> controller = StreamController<CustomEvent>();

  @internal
  final Map<String, Stream<CustomEvent>> typeMap = HashMap<String, Stream<CustomEvent>>();

  @internal
  Set<String> dirty = HashSet<String>();

  @internal
  void markDirty(String name) {
    if (dirty.isEmpty) {
      scheduleUpdateFor(this);
    }

    dirty.add(name);
  }

  Context get context;

  Fragment get fragment;

  void invalidate(String name, Object? oldValue, Object? newValue) {
    if (identical(oldValue, newValue)) {
      return;
    }

    markDirty(name);
  }

  Stream<CustomEvent<T>> on<T>(String type) {
    var stream = typeMap[type];

    if (stream == null) {
      typeMap[type] = stream = controller.stream.where((event) => event.type == type);
    }

    return stream.cast<CustomEvent<T>>();
  }

  void dispatch<T>(String type, [T? detail]) {
    controller.add(CustomEvent<T>(type, CustomEventOptions<T>(detail: detail)));
  }
}

void createComponent(Component component) {
  component.fragment.create();
}

void mountComponent(Component component, Element target, Node? anchor) {
  component.fragment.mount(target, anchor);
}

void detachComponent(Component component, bool detaching) {
  component.fragment.detach(detaching);
}
