import 'package:meta/dart2js.dart';
import 'package:svelte_web_runtime/src/component.dart';
import 'package:svelte_web_runtime/src/lifecycle.dart';
import 'package:svelte_web_runtime/src/utilities.dart';

List<Component> dirtyComponents = <Component>[];

List<void Function()> _bindingCallbacks = <void Function()>[];
List<void Function()> _renderCalbacks = <void Function()>[];
List<void Function()> _flushCallbacks = <void Function()>[];

Future<void> _resolvedFuture = Future<void>(noop);
bool _updateScheduled = false;

@noInline
void scheduleUpdate() {
  if (_updateScheduled) {
    return;
  }

  _updateScheduled = true;
  _resolvedFuture = Future<void>(flush);
}

@noInline
Future<void> tick() {
  scheduleUpdate();
  return _resolvedFuture;
}

void addRenderCallback(void Function() callback) {
  _renderCalbacks.add(callback);
}

void addFlushCallback(void Function() callback) {
  _flushCallbacks.add(callback);
}

Set<void Function()> _seenCallbacks = <void Function()>{};
int _flushIndex = 0;

@noInline
void flush() {
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
      dirtyComponents = <Component>[];
      _flushIndex = 0;
      rethrow;
    }

    setCurrentComponent(null);
    dirtyComponents = <Component>[];
    _flushIndex = 0;

    while (_bindingCallbacks.isNotEmpty) {
      _bindingCallbacks.removeLast()();
    }

    for (var i = 0; i < _renderCalbacks.length; i += 1) {
      var callback = _renderCalbacks[i];

      if (_seenCallbacks.add(callback)) {
        callback();
      }
    }

    _renderCalbacks = <void Function()>[];
  } while (dirtyComponents.isNotEmpty);

  while (_flushCallbacks.isNotEmpty) {
    _flushCallbacks.removeLast()();
  }

  _updateScheduled = false;
  setCurrentComponent(savedComponent);
}
