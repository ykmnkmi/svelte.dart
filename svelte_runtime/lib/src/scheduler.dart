import 'package:meta/dart2js.dart';
import 'package:meta/meta.dart';
import 'package:svelte_runtime/src/component.dart';
import 'package:svelte_runtime/src/lifecycle.dart';
import 'package:svelte_runtime/src/utilities.dart';

List<Component> dirtyComponents = <Component>[];

@protected
List<VoidFunction> bindingCallbacks = <VoidFunction>[];

@protected
List<VoidFunction> renderCalbacks = <VoidFunction>[];

@protected
List<VoidFunction> flushCallbacks = <VoidFunction>[];

@protected
Future<void> resolvedFuture = Future<void>(noop);

@protected
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

@protected
Set<void Function()> seenCallbacks = <VoidFunction>{};

@protected
int flushIndex = 0;

@noInline
void flush([void _]) {
  if (flushIndex != 0) {
    return;
  }

  var savedComponent = currentComponent;

  do {
    try {
      while (flushIndex < dirtyComponents.length) {
        var component = dirtyComponents[flushIndex++];
        setCurrentComponent(component);
        update(component.state);
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

    for (var i = 0; i < renderCalbacks.length; i += 1) {
      var callback = renderCalbacks[i];

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
  seenCallbacks = <VoidFunction>{};
  setCurrentComponent(savedComponent);
}

@noInline
@protected
void update(State state) {
  if (state.fragment case var fragment?) {
    state.update(state);
    runAll(state.beforeUpdate);

    var dirty = state.dirty;
    state.dirty = -1;
    fragment.update(state.instance, dirty);
    renderCalbacks.addAll(state.afterUpdate);
  }
}

void flushRenderCallbacks(List<VoidFunction> callbacks) {
  var filtered = <VoidFunction>[];
  var targets = <VoidFunction>[];

  for (var callback in renderCalbacks) {
    if (callbacks.contains(callback)) {
      targets.add(callback);
    } else {
      filtered.add(callback);
    }
  }

  targets.forEach(run);
  renderCalbacks = filtered;
}
