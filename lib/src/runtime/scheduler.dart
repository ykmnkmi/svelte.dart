import 'package:svelte/src/runtime/component.dart';
import 'package:svelte/src/runtime/lifecycle.dart';
import 'package:svelte/src/runtime/utilities.dart';

List<Component> dirtyComponents = <Component>[];

Future<void> resolvedFuture = Future<void>(noop);

bool updateScheduled = false;

void scheduleUpdate() {
  if (updateScheduled) {
    return;
  }

  updateScheduled = true;
  resolvedFuture = Future<void>(flush);
}

Future<void> tick() {
  scheduleUpdate();
  return resolvedFuture;
}

var flushIndex = 0;

void flush() {
  // TODO(runtime): check resolvedFuture and flushIndex
  if (flushIndex != 0) {
    return;
  }

  var savedComponent = currentComponent;

  do {
    try {
      while (flushIndex < dirtyComponents.length) {
        var component = dirtyComponents[flushIndex++];
        setCurrentComponent(component);
        updateComponent(component);
      }
    } catch (error) {
      dirtyComponents.clear();
      flushIndex = 0;
      rethrow;
    }

    setCurrentComponent(null);
    dirtyComponents.clear();
    flushIndex = 0;
  } while (dirtyComponents.isNotEmpty);

  updateScheduled = false;
  setCurrentComponent(savedComponent);
}
