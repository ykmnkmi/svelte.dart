import 'dart:html' show Element, Node;

import 'package:meta/dart2js.dart';
import 'package:svelte_runtime/src/fragment.dart';
import 'package:svelte_runtime/src/lifecycle.dart';
import 'package:svelte_runtime/src/scheduler.dart';
import 'package:svelte_runtime/src/state.dart';
import 'package:svelte_runtime/src/transition.dart';
import 'package:svelte_runtime/src/utilities.dart';

typedef InstanceFactory = List<Object?> Function(
  Component component,
  Map<String, Object?> props,
  Invalidate invalidate,
);

typedef Invalidate = void Function(
  int index,
  Object? value, [
  Object? expression,
]);

typedef PropertiesSetter = void Function(Map<String, Object?> props);

typedef UpdateFactory = void Function() Function(List<int> dirty);

abstract class Component {
  late final State state;

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

@tryInline
void setComponentUpdate(Component component, UpdateFactory updateFactory) {
  component.state.update = updateFactory(component.state.dirty);
}

@tryInline
void setComponentSet(Component component, PropertiesSetter setter) {
  component._set = setter;
}

typedef Options = ({
  Element? target,
  Node? anchor,
  Map<String, Object?>? props,
  bool hydrate,
  bool intro,
});

@noInline
void init({
  required Component component,
  required Options options,
  InstanceFactory? createInstance,
  FragmentFactory? createFragment,
  Map<String, int> props = const <String, int>{},
  void Function(Element? target)? appendStyles,
  List<int> dirty = const <int>[-1],
}) {
  Component? parentComponent = currentComponent;
  setCurrentComponent(component);

  Element? target = options.target;

  State state = State()
    ..root = target ?? parentComponent?.state.root
    ..props = props
    ..dirty = dirty;

  component.state = state;

  if (appendStyles != null) {
    appendStyles(target);
  }

  bool ready = false;

  if (createInstance != null) {
    void invalidate(int i, Object? value, [Object? expression]) {
      if (state.instance[i] != (state.instance[i] = value) ||
          expression != null) {
        if (ready) {
          makeComponentDirty(component, i);
        }
      }
    }

    state.instance = createInstance(
      component,
      options.props ?? <String, Object?>{},
      invalidate,
    );
  }

  state.update();
  ready = true;

  if (createFragment != null) {
    state.fragment = createFragment(state.instance);
  }

  if (target != null) {
    if (options.hydrate) {
      throw UnimplementedError();
    } else {
      state.fragment?.create();
    }

    if (options.intro) {
      transitionIn(state.fragment, false);
    }

    mountComponent(component, target, options.anchor);
    flush();
  }

  setCurrentComponent(parentComponent);
}

@noInline
void createComponent(Component component) {
  component.state.fragment?.create();
}

@noInline
void mountComponent(Component component, Element target, [Node? anchor]) {
  component.state.fragment?.mount(target, anchor);

  addRenderCallback(() {
    List<VoidFunction> newOnDestroy = component.state.onMount
        .map<Object?>(run)
        .whereType<VoidFunction>()
        .toList();

    if (component.state.destroyed) {
      component.state.onDestroy.addAll(newOnDestroy);
    } else {
      runAll(newOnDestroy);
    }

    component.state.onMount = <VoidFunction>[];
  });

  component.state.afterUpdate.forEach(addRenderCallback);
}

@noInline
void makeComponentDirty(Component component, int index) {
  int dirtyIndex = index ~/ 31;

  if (component.state.dirty[0] == -1) {
    dirtyComponents.add(component);
    scheduleUpdate();
    component.state.dirty = List<int>.filled(dirtyIndex + 1, 0);
  }

  component.state.dirty[dirtyIndex] |= 1 << index % 31;
}

@noInline
void updateComponent(Component component) {
  component.state.update();

  if (component.state.fragment case Fragment fragment?) {
    List<int> dirty = component.state.dirty;
    component.state.dirty = const <int>[-1];
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
  if (component.state.fragment case Fragment fragment?) {
    runAll(component.state.onDestroy);
    fragment.detach(detaching);

    component.state
      ..fragment = null
      ..instance = <Object?>[]
      ..onDestroy = <VoidFunction>[];
  }
}
