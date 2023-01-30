import 'dart:html';

import 'package:svelte/src/runtime/component.dart';
import 'package:svelte/src/runtime/lifecycle.dart';
import 'package:svelte/src/runtime/utilities.dart';

List<Component> dirtyComponents = <Component>[];

List<VoidCallback> bindingCallbacks = <VoidCallback>[];
List<VoidCallback> _renderCalbacks = <VoidCallback>[];
List<VoidCallback> _flushCallbacks = <VoidCallback>[];

Future<void> _resolvedFuture = Future<void>(noop);
bool _updateScheduled = false;

void scheduleUpdate() {
  if (_updateScheduled) {
    return;
  }

  _updateScheduled = true;
  _resolvedFuture = Future<void>(flush);
}

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

Set<VoidCallback> _seenCallbacks = <VoidCallback>{};
int _flushIndex = 0;

void flush() {
  // TODO(runtime): check resolvedFuture and flushIndex
  if (_flushIndex != 0) {
    return;
  }

  var savedComponent = currentComponent;

  do {
    try {
      while (_flushIndex < dirtyComponents.length) {
        var component = dirtyComponents[_flushIndex++];
        setCurrentComponent(component);
        updateComponent(component);
      }
    } catch (error) {
      dirtyComponents.clear();
      _flushIndex = 0;
      rethrow;
    }

    setCurrentComponent(null);
    dirtyComponents.clear();
    _flushIndex = 0;

    while (bindingCallbacks.isNotEmpty) {
      bindingCallbacks.removeLast()();
    }

    for (var i = 0; i < _renderCalbacks.length; i += 1) {
      var callback = _renderCalbacks[i];

      if (_seenCallbacks.add(callback)) {
        callback();
      }
    }

    _renderCalbacks.clear();
  } while (dirtyComponents.isNotEmpty);

  while (_flushCallbacks.isNotEmpty) {
    _flushCallbacks.removeLast()();
  }

  _updateScheduled = false;
  setCurrentComponent(savedComponent);
}
