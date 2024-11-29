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

typedef Invalidate = void Function(int index, Object? value,
    [Object? mutation]);

typedef PropertiesSetter = void Function(Map<String, Object?> props);

typedef UpdateFactory = void Function() Function(int dirty);

const Object undefined = Object();

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
  }) : state = State() {
    Component? parentComponent = currentComponent;
    setCurrentComponent(this);

    state
      ..root = target ?? parentComponent?.state.root
      ..dirty = dirty;

    if (appendStyles != null) {
      appendStyles(target);
    }

    bool ready = false;

    if (createInstance != null) {
      void invalidate(int i, Object? value, [Object? mutation = undefined]) {
        if (state.instance[i] == value || identical(mutation, undefined)) {
          return;
        }

        state.instance[i] = value;

        if (ready) {
          makeComponentDirty(this, i);
        }
      }

      state.instance = createInstance(this, properties, invalidate);
    }

    state.update();
    ready = true;
    runAll(state.beforeUpdate);

    if (createFragment != null) {
      state.fragment = createFragment(state.instance);
    }

    if (target != null) {
      if (hydrate) {
        throw UnimplementedError();
      } else {
        state.fragment?.create();
      }

      if (intro) {
        transitionIn(state.fragment, false);
      }

      mountComponent(this, target, anchor);
      flush();
    }

    setCurrentComponent(parentComponent);
  }

  final State state;

  PropertiesSetter? _set;

  bool get isDestroyed {
    return state.destroyed;
  }

  void set([Map<String, Object?>? props]) {
    PropertiesSetter? set = _set;

    if (set != null && props != null) {
      set(props);
    }
  }

  void destroy() {
    if (state.destroyed) {
      return;
    }

    destroyComponent(this, true);
    state.destroyed = true;
  }
}

void setComponentUpdate(Component component, UpdateFactory updateFactory) {
  component.state.update = updateFactory(component.state.dirty);
}

void setComponentSet(Component component, PropertiesSetter setter) {
  component._set = setter;
}

@noInline
void createComponent(Component component) {
  component.state.fragment?.create();
}

@noInline
void mountComponent(Component component, Element target, [Node? anchor]) {
  component.state.fragment?.mount(target, anchor);

  void callback() {
    List<VoidFunction> newOnDestroy = component.state.onMount
        .map<Object?>(run)
        .whereType<VoidFunction>()
        .toList();

    if (component.state.destroyed) {
      runAll(newOnDestroy);
    } else {
      component.state.onDestroy.addAll(newOnDestroy);
    }

    component.state.onMount = <VoidFunction>[];
  }

  addRenderCallback(callback);
  component.state.afterUpdate.forEach(addRenderCallback);
}

@noInline
void makeComponentDirty(Component component, int index) {
  if (component.state.dirty == -1) {
    dirtyComponents.add(component);
    scheduleUpdate();
    component.state.dirty = 0;
  }

  component.state.dirty |= 1 << index;
}

@noInline
void updateComponent(Component component) {
  component.state.update();

  if (component.state.fragment case var fragment?) {
    int dirty = component.state.dirty;
    component.state.dirty = -1;
    fragment.update(component.state.instance, dirty);
  }
}

@tryInline
void transitionInComponent(Component component, bool local) {
  transitionIn(component.state.fragment, local);
}

@tryInline
void transitionOutComponent(
  Component component,
  bool local, [
  void Function()? callback,
]) {
  transitionOut(component.state.fragment, local, callback);
}

@noInline
void destroyComponent(Component component, bool detaching) {
  if (component.state.fragment case var fragment?) {
    runAll(component.state.onDestroy);
    fragment.detach(detaching);

    component.state
      ..fragment = null
      ..instance = const <Object?>[]
      ..onDestroy = const <VoidFunction>[];
  }
}
