import 'package:meta/dart2js.dart';
import 'package:meta/meta.dart';
import 'package:svelte_web_runtime/src/component.dart';
import 'package:svelte_web_runtime/src/lifecycle.dart';
import 'package:svelte_web_runtime/src/utilities.dart';

@internal
List<Component> dirtyComponents = <Component>[];

@internal
List<VoidCallback> bindingCallbacks = <VoidCallback>[];

List<VoidCallback> _renderCalbacks = <VoidCallback>[];
List<VoidCallback> _flushCallbacks = <VoidCallback>[];
Future<void> _resolvedFuture = Future<void>(noop);
bool _updateScheduled = false;

@noInline
void scheduleUpdate() {
  if (_updateScheduled) {
    return;
  }

  _updateScheduled = true;
  _resolvedFuture = _resolvedFuture.then<void>(flush);
}

@noInline
Future<void> tick() {
  scheduleUpdate();
  return _resolvedFuture;
}

void addRenderCallback(VoidCallback callback) {
  _renderCalbacks.add(callback);
}

void addFlushCallback(VoidCallback callback) {
  _flushCallbacks.add(callback);
}

Set<void Function()> _seenCallbacks = <VoidCallback>{};
int _flushIndex = 0;

@noInline
void flush([void _]) {
  if (_flushIndex != 0) {
    return;
  }

  Component? savedComponent = currentComponent;

  do {
    try {
      while (_flushIndex < dirtyComponents.length) {
        Component component = dirtyComponents[_flushIndex++];
        setCurrentComponent(component);
        updateComponent(component);
      }
    } catch (error) {
      dirtyComponents = <Component>[];
      _flushIndex = 0;
      rethrow;
    }

    setCurrentComponent(null);
    dirtyComponents = <Component>[];
    _flushIndex = 0;

    while (bindingCallbacks.isNotEmpty) {
      bindingCallbacks.removeLast()();
    }

    for (int i = 0; i < _renderCalbacks.length; i += 1) {
      VoidCallback callback = _renderCalbacks[i];

      if (_seenCallbacks.add(callback)) {
        callback();
      }
    }

    _renderCalbacks = <VoidCallback>[];
  } while (dirtyComponents.isNotEmpty);

  while (_flushCallbacks.isNotEmpty) {
    _flushCallbacks.removeLast()();
  }

  _updateScheduled = false;
  setCurrentComponent(savedComponent);
}
