import 'dart:async';
import 'dart:collection';

import 'package:piko/src/runtime/component.dart';

List<Component> components = <Component>[];

bool updateScheduled = false;

int flushIndex = 0;

void flush() {
  do {
    while (flushIndex < components.length) {
      var component = components[flushIndex];
      flushIndex += 1;
      update(component);
    }

    components = <Component>[];
    flushIndex = 0;
  } while (components.isNotEmpty);

  updateScheduled = false;
}

void update(Component component) {
  var dirty = component.dirty;

  component
    ..dirty = HashSet<String>()
    ..update(dirty);
}

void scheduleUpdate() {
  if (updateScheduled) {
    return;
  }

  updateScheduled = true;
  scheduleMicrotask(flush);
}

void scheduleUpdateFor(Component component) {
  components.add(component);
  scheduleUpdate();
}
