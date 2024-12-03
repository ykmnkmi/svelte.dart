import 'package:meta/dart2js.dart';
import 'package:svelte_runtime/src/fragment.dart';
import 'package:svelte_runtime/src/lifecycle.dart';
import 'package:svelte_runtime/src/scheduler.dart';
import 'package:svelte_runtime/src/state.dart';
import 'package:svelte_runtime/src/transition.dart';
import 'package:svelte_runtime/src/utilities.dart';
import 'package:web/web.dart' show Element, Node;

typedef InstanceFactory = List<Object?> Function(
  Component component,
  Map<String, Object?> props,
  Invalidate invalidate,
);

typedef Invalidate = void Function(
  int index,
  Object? value, [
  Object? mutation,
]);

typedef PropertiesSetter = void Function(Map<String, Object?> props);

typedef UpdateFactory = void Function(State state) Function();

abstract base class Component {
  Component({
    Element? target,
    Node? anchor,
    Map<String, Object?> properties = const <String, Object?>{},
    bool hydrate = false,
    bool intro = false,
    InstanceFactory? createInstance,
    FragmentFactory? createFragment,
    void Function(Element? target)? appendStyles,
    int dirty = -1,
  }) : _state = State() {
    Component? parentComponent = currentComponent;
    setCurrentComponent(this);

    _state
      ..root = target ?? parentComponent?._state.root
      ..dirty = dirty;

    if (appendStyles != null) {
      appendStyles(target);
    }

    bool ready = false;

    if (createInstance != null) {
      void invalidate(int i, Object? value, [Object? mutation = undefined]) {
        if (!identical(mutation, undefined)) {
          value = mutation;
        }

        if (identical(_state.instance[i], value)) {
          return;
        }

        _state.instance[i] = value;

        if (ready) {
          makeComponentDirty(this, i);
        }
      }

      _state.instance = createInstance(this, properties, invalidate);
    }

    _state.update(_state);
    ready = true;
    runAll(_state.beforeUpdate);

    if (createFragment != null) {
      _state.fragment = createFragment(_state.instance);
    }

    if (target != null) {
      if (hydrate) {
        throw UnimplementedError();
      } else {
        _state.fragment?.create();
      }

      if (intro) {
        transitionIn(_state.fragment, false);
      }

      mountComponent(this, target, anchor);
      flush();
    }

    setCurrentComponent(parentComponent);
  }

  final State _state;

  PropertiesSetter? _set;

  bool get isDestroyed {
    return _state.destroyed;
  }

  void set([Map<String, Object?>? props]) {
    PropertiesSetter? set = _set;

    if (set != null && props != null) {
      set(props);
    }
  }

  void destroy() {
    if (_state.destroyed) {
      return;
    }

    destroyComponent(this, true);
    _state.destroyed = true;
  }
}

void setComponentUpdate(Component component, UpdateFactory updateFactory) {
  component._state.update = updateFactory();
}

void setComponentSet(Component component, PropertiesSetter setter) {
  component._set = setter;
}

@noInline
void createComponent(Component component) {
  component._state.fragment?.create();
}

@noInline
void mountComponent(Component component, Element target, [Node? anchor]) {
  component._state.fragment?.mount(target, anchor);

  void callback() {
    List<VoidFunction> newOnDestroy = component._state.onMount
        .map<Object?>(run)
        .whereType<VoidFunction>()
        .toList();

    if (component._state.onDestroy.isNotEmpty) {
      component._state.onDestroy.addAll(newOnDestroy);
    } else {
      runAll(newOnDestroy);
    }

    component._state.onMount = <VoidFunction>[];
  }

  addRenderCallback(callback);
  component._state.afterUpdate.forEach(addRenderCallback);
}

@noInline
void makeComponentDirty(Component component, int index) {
  State state = component._state;

  if (state.dirty == -1) {
    dirtyComponents.add(component);
    scheduleUpdate();
    state.dirty = 0;
  }

  state.dirty |= 1 << index;
}

@noInline
void updateComponent(Component component) {
  State state = component._state;

  if (state.fragment case var fragment?) {
    state.update(state);
    runAll(state.beforeUpdate);

    int dirty = state.dirty;
    state.dirty = -1;
    fragment.update(state.instance, dirty);
  }
}

@tryInline
void transitionInComponent(Component component, bool local) {
  transitionIn(component._state.fragment, local);
}

@tryInline
void transitionOutComponent(
  Component component,
  bool local, [
  void Function()? callback,
]) {
  transitionOut(component._state.fragment, local, callback);
}

@noInline
void destroyComponent(Component component, bool detaching) {
  State state = component._state;

  if (state.fragment case var fragment?) {
    runAll(state.onDestroy);
    fragment.detach(detaching);

    state
      ..onDestroy = const <VoidFunction>[]
      ..fragment = null
      ..instance = const <Object?>[];
  }
}
