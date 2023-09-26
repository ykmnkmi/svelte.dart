import 'package:meta/dart2js.dart';
import 'package:svelte_web_runtime/src/component.dart';
import 'package:svelte_web_runtime/src/lifecycle.dart';
import 'package:svelte_web_runtime/src/utilities.dart';

List<Component> dirtyComponents = <Component>[];

List<VoidFunction> bindingCallbacks = <VoidFunction>[];

List<VoidFunction> renderCalbacks = <VoidFunction>[];

List<VoidFunction> flushCallbacks = <VoidFunction>[];

Future<void> resolvedFuture = Future<void>(noop);

bool updateScheduled = false;

@noInline
void scheduleUpdate() {
  if (!updateScheduled) {
    updateScheduled = true;
    resolvedFuture = resolvedFuture.then<void>(flush);
  }
}

@noInline
Future<void> tick() {
  scheduleUpdate();
  return resolvedFuture;
}

void addRenderCallback(VoidFunction callback) {
  renderCalbacks.add(callback);
}

void addFlushCallback(VoidFunction callback) {
  flushCallbacks.add(callback);
}

Set<void Function()> seenCallbacks = <VoidFunction>{};

int flushIndex = 0;

@noInline
void flush([void _]) {
  if (flushIndex != 0) {
    return;
  }

  Component? savedComponent = currentComponent;

  do {
    try {
      while (flushIndex < dirtyComponents.length) {
        Component component = dirtyComponents[flushIndex++];
        setCurrentComponent(component);
        updateComponent(component);
      }
    } catch (error) {
      dirtyComponents = <Component>[];
      flushIndex = 0;
      rethrow;
    }

    setCurrentComponent(null);
    dirtyComponents = <Component>[];
    flushIndex = 0;

    while (bindingCallbacks.isNotEmpty) {
      bindingCallbacks.removeLast()();
    }

    for (int i = 0; i < renderCalbacks.length; i += 1) {
      VoidFunction callback = renderCalbacks[i];

      if (seenCallbacks.add(callback)) {
        callback();
      }
    }

    renderCalbacks = <VoidFunction>[];
  } while (dirtyComponents.isNotEmpty);

  while (flushCallbacks.isNotEmpty) {
    flushCallbacks.removeLast()();
  }

  updateScheduled = false;
  setCurrentComponent(savedComponent);
}
