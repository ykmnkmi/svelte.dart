import 'dart:async';
import 'dart:collection';

import 'package:meta/dart2js.dart';
import 'package:piko/src/runtime/component.dart';

List<Component> components = <Component>[];

bool updateScheduled = false;

int flushIndex = 0;

@noInline
void update(Component component) {
  var changed = component.dirty;
  component
    ..dirty = HashSet<String>()
    ..context.update(changed)
    ..fragment.update(changed);
}

@noInline
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

@noInline
void scheduleUpdate() {
  if (updateScheduled) {
    return;
  }

  updateScheduled = true;
  scheduleMicrotask(flush);
}

@noInline
void scheduleUpdateFor(Component component) {
  components.add(component);
  scheduleUpdate();
}
