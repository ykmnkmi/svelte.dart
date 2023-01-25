import 'dart:html' show Element, Node;

import 'package:svelte/src/runtime/fragment.dart';
import 'package:svelte/src/runtime/scheduler.dart';

abstract class Component {
  List<int> _dirty = <int>[-1];

  Fragment get _fragment;

  List<Object?> get _values;

  void _onChanges() {}

  void _onMount() {}

  void _beforeUpdate() {}

  void _afterUpdate() {}

  void _onDestroy() {}

  void destroy() {
    destroyComponent(this, true);
  }
}

void createComponent(Component component) {
  component
    .._onChanges()
    .._beforeUpdate()
    .._fragment.create();
}

void mountComponent(Component component, Element target, [Node? anchor]) {
  component._fragment.mount(target, anchor);
  addRenderCallback(component._onMount);
  addRenderCallback(component._afterUpdate);
}

void makeComponentDirty(Component component, int index) {
  var dirty = component._dirty;

  if (dirty[0] == -1) {
    dirtyComponents.add(component);
    scheduleUpdate();
    dirty.fillRange(0, dirty.length, 0);
  }
}

void invalidateComponent(Component component, int index, Object? value) {
  var values = component._values;
  if (identical(values[index], value)) {
    return;
  }

  values[index] = value;
  makeComponentDirty(component, index);
}

void updateComponent(Component component) {
  component._onChanges();

  var dirty = component._dirty;

  component
    .._beforeUpdate()
    .._dirty = <int>[-1]
    .._fragment.update(dirty);

  addRenderCallback(component._afterUpdate);
}

void destroyComponent(Component component, bool detaching) {
  component
    .._onDestroy()
    .._fragment.detach(detaching);
}
