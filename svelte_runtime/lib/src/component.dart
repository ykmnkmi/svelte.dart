import 'package:meta/dart2js.dart';
import 'package:meta/meta.dart';
import 'package:svelte_runtime/src/dom.dart';
import 'package:svelte_runtime/src/fragment.dart';
import 'package:svelte_runtime/src/lifecycle.dart';
import 'package:svelte_runtime/src/scheduler.dart';
import 'package:svelte_runtime/src/transition.dart';
import 'package:svelte_runtime/src/utilities.dart';
import 'package:web/web.dart' show Event, Element, Node;

typedef InstanceFactory = List<Object?> Function(
  Component component,
  Map<String, Object?> inputs,
  Invalidate invalidate,
);

typedef Invalidate = void Function(
  int index,
  Object? value, [
  Object? mutation,
]);

typedef InputsSetter = void Function(Map<String, Object?> inputs);

typedef UpdateFactory = void Function(State state) Function();

@noInline
void bind(Component component, String name, void Function(Object?) callback) {
  State state = component.state;
  int? index = state.properties[name];

  if (index != null) {
    state.bound[index] = callback;
    callback(state.instance[index]);
  }
}

@noInline
void createComponent(Component component) {
  State state = component.state;
  state.fragment?.create(state.instance);
}

@noInline
void claimComponent(Component component, List<Node> parentNodes) {
  component.state.fragment?.claim(parentNodes);
}

@noInline
void mountComponent(Component component, Element target, [Node? anchor]) {
  State state = component.state;

  state.fragment?.mount(state.instance, target, anchor);

  void callback() {
    var newOnDestroy =
        state.onMount.map<Object?>(run).whereType<VoidFunction>().toList();

    if (component.state.onDestroy case var onDestroy?) {
      onDestroy.addAll(newOnDestroy);
    } else {
      runAll(newOnDestroy);
    }

    component.state.onMount = <VoidFunction>[];
  }

  addRenderCallback(callback);
  component.state.afterUpdate.forEach(addRenderCallback);
}

@noInline
void destroyComponent(Component component, bool detaching) {
  var state = component.state;

  if (state.fragment case var fragment?) {
    flushRenderCallbacks(state.afterUpdate);
    runAll(state.onDestroy!);
    fragment.detach(detaching);

    state
      ..fragment = null
      ..instance = const <Never>[]
      ..update = noop
      ..bound = const <Never, Never>{}
      ..onMount = const <Never>[]
      ..onDestroy = null
      ..beforeUpdate = const <Never>[]
      ..afterUpdate = const <Never>[]
      ..context = null
      ..callbacks = const <Never, Never>{}
      ..root = null;
  }
}

@noInline
void makeComponentDirty(Component component, int index) {
  var state = component.state;

  if (state.dirty == -1) {
    dirtyComponents.add(component);
    scheduleUpdate();
    state.dirty = 0;
  }

  state.dirty |= 1 << index;
}

void setComponentUpdate(Component component, UpdateFactory updateFactory) {
  component.state.update = updateFactory();
}

void setComponentSetter(Component component, InputsSetter setter) {
  component.setter = setter;
}

final class State {
  Fragment? fragment;

  late List<Object?> instance;

  late Map<String, int> properties;

  late void Function(State state) update;

  late Map<Object, void Function(Object?)> bound;

  late List<VoidFunction> onMount;

  List<VoidFunction>? onDestroy;

  late List<VoidFunction> beforeUpdate;

  late List<VoidFunction> afterUpdate;

  Map<String, Object?>? context;

  late Map<String, List<void Function(Event)>> callbacks;

  late int dirty;

  late bool skipBound;

  Element? root;
}

abstract base class Component {
  Component({
    Element? target,
    Node? anchor,
    Map<String, Object?> inputs = const <Never, Never>{},
    bool hydrate = false,
    bool intro = false,
    Map<String, Object?>? context,
    InstanceFactory? createInstance,
    FragmentFactory? createFragment,
    Map<String, int> properties = const <Never, Never>{},
    void Function(Element? target)? appendStyles,
    int dirty = -1,
  }) : state = State() {
    Component? parent = currentComponent;
    setCurrentComponent(this);

    state
      ..properties = properties
      ..update = noop
      ..bound = <Object, void Function(Object?)>{}
      ..onMount = <VoidFunction>[]
      ..onDestroy = <VoidFunction>[]
      ..beforeUpdate = <VoidFunction>[]
      ..afterUpdate = <VoidFunction>[]
      ..context = context ?? parent?.state.context ?? <String, Object?>{}
      ..callbacks = <String, List<void Function(Event)>>{}
      ..dirty = dirty
      ..skipBound = false
      ..root = target ?? parent?.state.root;

    if (appendStyles != null) {
      appendStyles(target);
    }

    bool ready = false;

    if (createInstance == null) {
      state.instance = const <Never>[];
    } else {
      void invalidate(int i, Object? value, [Object? mutation = undefined]) {
        if (state.instance[i] == value && mutation == undefined) {
          return;
        }

        state.instance[i] = value;

        if (!state.skipBound && state.bound[i] != null) {
          state.bound[i]!(value);
        }

        if (ready) {
          makeComponentDirty(this, i);
        }
      }

      state.instance = createInstance(this, inputs, invalidate);
    }

    state.update(state);
    ready = true;
    runAll(state.beforeUpdate);

    if (createFragment == null) {
      state.fragment = Fragment.empty;
    } else {
      state.fragment = createFragment(state.instance);
    }

    if (target != null) {
      if (hydrate) {
        startHydrating();

        List<Node> nodes = children(target);
        state.fragment?.claim(nodes);
        nodes.forEach(remove);
      } else {
        state.fragment?.create(state.instance);
      }

      if (intro) {
        transitionIn(state.fragment, false);
      }

      mountComponent(this, target, anchor);
      endHydrating();
      flush();
    }

    setCurrentComponent(parent);
  }

  @internal
  final State state;

  @internal
  InputsSetter? setter;

  bool get isDestroyed {
    return state.onDestroy == null;
  }

  void on(String type, void Function(Event event) callback) {
    (state.callbacks[type] ??= <void Function(Event)>[]).add(callback);
  }

  void off(String type, void Function(Event event) callback) {
    state.callbacks[type]?.remove(callback);
  }

  void set([Map<String, Object?>? inputs]) {
    InputsSetter? set = setter;

    if (set != null && inputs != null) {
      state.skipBound = true;
      set(inputs);
      state.skipBound = false;
    }
  }

  void destroy() {
    if (isDestroyed) {
      return;
    }

    destroyComponent(this, true);
  }
}
