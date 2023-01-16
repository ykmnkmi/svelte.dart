import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';

import 'package:svelte/src/runtime/component.dart';

@protected
List<void Function()> renderCallbacks = <void Function()>[];

@protected
List<Component> dirtyComponents = <Component>[];

@protected
bool updateScheduled = false;

@protected
void update(Component component) {
  component.afterChanges();

  var changed = component.dirty;

  component
    ..beforeUpdate()
    ..dirty = HashSet<String>()
    ..fragment.update(changed);

  addRenderCallback(component.afterUpdate);
}

@protected
void flush() {
  assert(updateScheduled);

  do {
    var components = dirtyComponents;
    dirtyComponents = <Component>[];

    for (var i = 0; i < components.length; i += 1) {
      update(components[i]);
    }

    var callbacks = renderCallbacks;
    renderCallbacks = <void Function()>[];

    for (var i = 0; i < callbacks.length; i += 1) {
      callbacks[i]();
    }
  } while (dirtyComponents.isNotEmpty);

  updateScheduled = false;
}

@protected
void scheduleUpdate() {
  if (!updateScheduled) {
    updateScheduled = true;
    scheduleMicrotask(flush);
  }
}

void addRenderCallback(void Function() callback) {
  renderCallbacks.add(callback);
}

void scheduleUpdateFor(Component component) {
  dirtyComponents.add(component);
  scheduleUpdate();
}
