(function(global, factory) {
  typeof exports === "object" && typeof module !== "undefined" ? module.exports = factory() : typeof define === "function" && define.amd ? define(factory) : (global = typeof globalThis !== "undefined" ? globalThis : global || self, global.$$ = factory());
})(this, function() {
  "use strict";var __defProp = Object.defineProperty;
var __defNormalProp = (obj, key, value) => key in obj ? __defProp(obj, key, { enumerable: true, configurable: true, writable: true, value }) : obj[key] = value;
var __publicField = (obj, key, value) => {
  __defNormalProp(obj, typeof key !== "symbol" ? key + "" : key, value);
  return value;
};
var __accessCheck = (obj, member, msg) => {
  if (!member.has(obj))
    throw TypeError("Cannot " + msg);
};
var __privateGet = (obj, member, getter) => {
  __accessCheck(obj, member, "read from private field");
  return getter ? getter.call(obj) : member.get(obj);
};
var __privateAdd = (obj, member, value) => {
  if (member.has(obj))
    throw TypeError("Cannot add the same private member more than once");
  member instanceof WeakSet ? member.add(obj) : member.set(obj, value);
};
var __privateSet = (obj, member, value, setter) => {
  __accessCheck(obj, member, "write to private field");
  setter ? setter.call(obj, value) : member.set(obj, value);
  return value;
};
var __privateMethod = (obj, member, method) => {
  __accessCheck(obj, member, "access private method");
  return method;
};

  var _tick_fn, _duration, _current, _delay, _previous, _reversed, _delay_current, _delayed_reverse, _reverse, reverse_fn, _listeners, _observer, _options, _getObserver, getObserver_fn, _events, _instance;
  const EMPTY_FUNC = () => {
  };
  function is_promise(value) {
    return typeof (value == null ? void 0 : value.then) === "function";
  }
  function run_all(arr) {
    for (var i = 0; i < arr.length; i++) {
      arr[i]();
    }
  }
  function subscribe_to_store(store, run, invalidate) {
    if (store == null) {
      run(void 0);
      if (invalidate)
        invalidate(void 0);
      return EMPTY_FUNC;
    }
    const unsub = store.subscribe(
      run,
      // @ts-expect-error
      invalidate
    );
    return unsub.unsubscribe ? () => unsub.unsubscribe() : unsub;
  }
  var is_array = Array.isArray;
  var array_from = Array.from;
  var object_keys = Object.keys;
  var object_assign = Object.assign;
  var define_property = Object.defineProperty;
  var get_descriptor = Object.getOwnPropertyDescriptor;
  var get_descriptors = Object.getOwnPropertyDescriptors;
  function is_function(thing) {
    return typeof thing === "function";
  }
  const EACH_ITEM_REACTIVE = 1;
  const EACH_INDEX_REACTIVE = 1 << 1;
  const EACH_KEYED = 1 << 2;
  const EACH_IS_CONTROLLED = 1 << 3;
  const EACH_IS_ANIMATED = 1 << 4;
  const EACH_IS_IMMUTABLE = 1 << 6;
  const PROPS_IS_IMMUTABLE = 1;
  const PROPS_IS_UPDATED = 1 << 2;
  const PROPS_IS_LAZY_INITIAL = 1 << 3;
  const DelegatedEvents = [
    "beforeinput",
    "click",
    "dblclick",
    "contextmenu",
    "focusin",
    "focusout",
    // 'input', This conflicts with bind:input
    "keydown",
    "keyup",
    "mousedown",
    "mousemove",
    "mouseout",
    "mouseover",
    "mouseup",
    "pointerdown",
    "pointermove",
    "pointerout",
    "pointerover",
    "pointerup",
    "touchend",
    "touchmove",
    "touchstart"
  ];
  const PassiveDelegatedEvents = ["touchstart", "touchmove", "touchend"];
  const AttributeAliases = {
    // no `class: 'className'` because we handle that separately
    formnovalidate: "formNoValidate",
    ismap: "isMap",
    nomodule: "noModule",
    playsinline: "playsInline",
    readonly: "readOnly"
  };
  const STATE_SYMBOL = Symbol("$state");
  const READONLY_SYMBOL = Symbol("readonly");
  const object_prototype = Object.prototype;
  const array_prototype = Array.prototype;
  const get_prototype_of = Object.getPrototypeOf;
  const is_frozen$1 = Object.isFrozen;
  function proxy(value, immutable = true) {
    if (typeof value === "object" && value != null && !is_frozen$1(value)) {
      if (STATE_SYMBOL in value) {
        return (
          /** @type {T} */
          value[STATE_SYMBOL].p
        );
      }
      const prototype = get_prototype_of(value);
      if (prototype === object_prototype || prototype === array_prototype) {
        const proxy2 = new Proxy(value, handler$1);
        define_property(value, STATE_SYMBOL, {
          value: init(value, proxy2, immutable),
          writable: false
        });
        return proxy2;
      }
    }
    return value;
  }
  function unwrap$1(value, already_unwrapped = /* @__PURE__ */ new Map()) {
    if (typeof value === "object" && value != null && !is_frozen$1(value) && STATE_SYMBOL in value) {
      const unwrapped = already_unwrapped.get(value);
      if (unwrapped !== void 0) {
        return unwrapped;
      }
      if (is_array(value)) {
        const array = [];
        already_unwrapped.set(value, array);
        for (const element2 of value) {
          array.push(unwrap$1(element2, already_unwrapped));
        }
        return array;
      } else {
        const obj = {};
        const keys = object_keys(value);
        const descriptors = get_descriptors(value);
        already_unwrapped.set(value, obj);
        for (const key2 of keys) {
          if (descriptors[key2].get) {
            define_property(obj, key2, descriptors[key2]);
          } else {
            const property = value[key2];
            obj[key2] = unwrap$1(property, already_unwrapped);
          }
        }
        return obj;
      }
    }
    return value;
  }
  function unstate(value) {
    return (
      /** @type {T} */
      unwrap$1(
        /** @type {StateObject} */
        value
      )
    );
  }
  function init(value, proxy2, immutable) {
    return {
      s: /* @__PURE__ */ new Map(),
      v: /* @__PURE__ */ source(0),
      a: is_array(value),
      i: immutable,
      p: proxy2
    };
  }
  const handler$1 = {
    defineProperty(target, prop2, descriptor) {
      if (descriptor.value) {
        const metadata = target[STATE_SYMBOL];
        const s = metadata.s.get(prop2);
        if (s !== void 0)
          set(s, proxy(descriptor.value, metadata.i));
      }
      return Reflect.defineProperty(target, prop2, descriptor);
    },
    deleteProperty(target, prop2) {
      const metadata = target[STATE_SYMBOL];
      const s = metadata.s.get(prop2);
      if (s !== void 0)
        set(s, UNINITIALIZED);
      if (prop2 in target)
        update(metadata.v);
      return delete target[prop2];
    },
    get(target, prop2, receiver) {
      var _a;
      const metadata = target[STATE_SYMBOL];
      let s = metadata.s.get(prop2);
      if (s === void 0 && (effect_active() || updating_derived) && (!(prop2 in target) || ((_a = get_descriptor(target, prop2)) == null ? void 0 : _a.writable))) {
        s = (metadata.i ? source : mutable_source)(proxy(target[prop2], metadata.i));
        metadata.s.set(prop2, s);
      }
      const value = s !== void 0 ? get(s) : Reflect.get(target, prop2, receiver);
      return value === UNINITIALIZED ? void 0 : value;
    },
    getOwnPropertyDescriptor(target, prop2) {
      const descriptor = Reflect.getOwnPropertyDescriptor(target, prop2);
      if (descriptor && "value" in descriptor) {
        const metadata = target[STATE_SYMBOL];
        const s = metadata.s.get(prop2);
        if (s) {
          descriptor.value = get(s);
        }
      }
      return descriptor;
    },
    has(target, prop2) {
      var _a;
      if (prop2 === STATE_SYMBOL) {
        return true;
      }
      const metadata = target[STATE_SYMBOL];
      const has = Reflect.has(target, prop2);
      let s = metadata.s.get(prop2);
      if (s !== void 0 || effect_active() && (!has || ((_a = get_descriptor(target, prop2)) == null ? void 0 : _a.writable))) {
        if (s === void 0) {
          s = (metadata.i ? source : mutable_source)(
            has ? proxy(target[prop2], metadata.i) : UNINITIALIZED
          );
          metadata.s.set(prop2, s);
        }
        const value = get(s);
        if (value === UNINITIALIZED) {
          return false;
        }
      }
      return has;
    },
    set(target, prop2, value) {
      const metadata = target[STATE_SYMBOL];
      const s = metadata.s.get(prop2);
      if (s !== void 0)
        set(s, proxy(value, metadata.i));
      const is_array2 = metadata.a;
      const not_has = !(prop2 in target);
      if (is_array2 && prop2 === "length") {
        for (let i = value; i < target.length; i += 1) {
          const s2 = metadata.s.get(i + "");
          if (s2 !== void 0)
            set(s2, UNINITIALIZED);
        }
      }
      if (not_has) {
        update(metadata.v);
      }
      target[prop2] = value;
      if (is_array2 && not_has) {
        const ls = metadata.s.get("length");
        const length = target.length;
        if (ls !== void 0 && ls.v !== length) {
          set(ls, length);
        }
      }
      return true;
    },
    ownKeys(target) {
      const metadata = target[STATE_SYMBOL];
      get(metadata.v);
      return Reflect.ownKeys(target);
    }
  };
  const is_frozen = Object.isFrozen;
  function readonly(value) {
    const proxy2 = value && value[READONLY_SYMBOL];
    if (proxy2)
      return proxy2;
    if (typeof value === "object" && value != null && !is_frozen(value) && STATE_SYMBOL in value && // TODO handle Map and Set as well
    !(READONLY_SYMBOL in value)) {
      const proxy3 = new Proxy(value, handler);
      define_property(value, READONLY_SYMBOL, { value: proxy3, writable: false });
      return proxy3;
    }
    return value;
  }
  const readonly_error = (_, prop2) => {
    throw new Error(
      `Non-bound props cannot be mutated — use \`bind:<prop>={...}\` to make \`${prop2}\` settable. Fallback values can never be mutated.`
    );
  };
  const handler = {
    defineProperty: readonly_error,
    deleteProperty: readonly_error,
    set: readonly_error,
    get(target, prop2, receiver) {
      const value = Reflect.get(target, prop2, receiver);
      if (!(prop2 in target)) {
        return readonly(value);
      }
      return value;
    }
  };
  const SOURCE = 1;
  const DERIVED = 1 << 1;
  const EFFECT = 1 << 2;
  const PRE_EFFECT = 1 << 3;
  const RENDER_EFFECT = 1 << 4;
  const MANAGED = 1 << 6;
  const UNOWNED = 1 << 7;
  const CLEAN = 1 << 8;
  const DIRTY = 1 << 9;
  const MAYBE_DIRTY = 1 << 10;
  const INERT = 1 << 11;
  const DESTROYED = 1 << 12;
  const IS_EFFECT = EFFECT | PRE_EFFECT | RENDER_EFFECT;
  const FLUSH_MICROTASK = 0;
  const FLUSH_SYNC = 1;
  const UNINITIALIZED = Symbol();
  const LAZY_PROPERTY = Symbol();
  let current_scheduler_mode = FLUSH_MICROTASK;
  let is_micro_task_queued = false;
  let is_task_queued = false;
  let current_queued_pre_and_render_effects = [];
  let current_queued_effects = [];
  let current_queued_tasks = [];
  let flush_count = 0;
  let current_consumer = null;
  let current_effect = null;
  let current_dependencies = null;
  let current_dependencies_index = 0;
  let current_untracked_writes = null;
  let current_untracking = false;
  let ignore_mutation_validation = false;
  let current_skip_consumer = false;
  let is_signals_recorded = false;
  let captured_signals = /* @__PURE__ */ new Set();
  let inspect_captured_signals = [];
  let current_block = null;
  let current_component_context = null;
  let updating_derived = false;
  function is_runes(context) {
    const component_context = context || current_component_context;
    return component_context !== null && component_context.r;
  }
  function default_equals(a, b) {
    return a === b;
  }
  function create_source_signal(flags, value) {
    return {
      // consumers
      c: null,
      // equals
      e: default_equals,
      // flags
      f: flags,
      // value
      v: value,
      // context: We can remove this if we get rid of beforeUpdate/afterUpdate
      x: null
    };
  }
  function create_computation_signal(flags, value, block) {
    return {
      // block
      b: block,
      // consumers
      c: null,
      // destroy
      d: null,
      // equals
      e: null,
      // flags
      f: flags,
      // init
      i: null,
      // references
      r: null,
      // value
      v: value,
      // context: We can remove this if we get rid of beforeUpdate/afterUpdate
      x: null,
      // destroy
      y: null
    };
  }
  function push_reference(target_signal, ref_signal) {
    const references = target_signal.r;
    if (references === null) {
      target_signal.r = [ref_signal];
    } else {
      references.push(ref_signal);
    }
  }
  function is_signal_dirty(signal) {
    const flags = signal.f;
    if ((flags & DIRTY) !== 0 || signal.v === UNINITIALIZED) {
      return true;
    }
    if ((flags & MAYBE_DIRTY) !== 0) {
      const dependencies = (
        /** @type {import('./types.js').ComputationSignal<V>} **/
        signal.d
      );
      if (dependencies !== null) {
        const length = dependencies.length;
        let i;
        for (i = 0; i < length; i++) {
          const dependency = dependencies[i];
          if ((dependency.f & MAYBE_DIRTY) !== 0 && !is_signal_dirty(dependency)) {
            set_signal_status(dependency, CLEAN);
            continue;
          }
          if ((dependency.f & DIRTY) !== 0) {
            if ((dependency.f & DERIVED) !== 0) {
              update_derived(
                /** @type {import('./types.js').ComputationSignal<V>} **/
                dependency,
                true
              );
              if ((signal.f & DIRTY) !== 0) {
                return true;
              }
            } else {
              return true;
            }
          }
        }
      }
    }
    return false;
  }
  function execute_signal_fn(signal) {
    const init2 = signal.i;
    const previous_dependencies = current_dependencies;
    const previous_dependencies_index = current_dependencies_index;
    const previous_untracked_writes = current_untracked_writes;
    const previous_consumer = current_consumer;
    const previous_block = current_block;
    const previous_component_context = current_component_context;
    const previous_skip_consumer = current_skip_consumer;
    const is_render_effect = (signal.f & RENDER_EFFECT) !== 0;
    const previous_untracking = current_untracking;
    current_dependencies = /** @type {null | import('./types.js').Signal[]} */
    null;
    current_dependencies_index = 0;
    current_untracked_writes = null;
    current_consumer = signal;
    current_block = signal.b;
    current_component_context = signal.x;
    current_skip_consumer = current_effect === null && (signal.f & UNOWNED) !== 0;
    current_untracking = false;
    if (is_render_effect && (current_component_context == null ? void 0 : current_component_context.u) != null) {
      current_component_context.u.e();
    }
    try {
      let res;
      if (is_render_effect) {
        res = /** @type {(block: import('./types.js').Block) => V} */
        init2(
          /** @type {import('./types.js').Block} */
          signal.b
        );
      } else {
        res = /** @type {() => V} */
        init2();
      }
      let dependencies = (
        /** @type {import('./types.js').Signal<unknown>[]} **/
        signal.d
      );
      if (current_dependencies !== null) {
        let i;
        remove_consumer(signal, current_dependencies_index, false);
        if (dependencies !== null && current_dependencies_index > 0) {
          dependencies.length = current_dependencies_index + current_dependencies.length;
          for (i = 0; i < current_dependencies.length; i++) {
            dependencies[current_dependencies_index + i] = current_dependencies[i];
          }
        } else {
          signal.d = /** @type {import('./types.js').Signal<V>[]} **/
          dependencies = current_dependencies;
        }
        if (!current_skip_consumer) {
          for (i = current_dependencies_index; i < dependencies.length; i++) {
            const dependency = dependencies[i];
            if (dependency.c === null) {
              dependency.c = [signal];
            } else {
              dependency.c.push(signal);
            }
          }
        }
      } else if (dependencies !== null && current_dependencies_index < dependencies.length) {
        remove_consumer(signal, current_dependencies_index, false);
        dependencies.length = current_dependencies_index;
      }
      return res;
    } finally {
      current_dependencies = previous_dependencies;
      current_dependencies_index = previous_dependencies_index;
      current_untracked_writes = previous_untracked_writes;
      current_consumer = previous_consumer;
      current_block = previous_block;
      current_component_context = previous_component_context;
      current_skip_consumer = previous_skip_consumer;
      current_untracking = previous_untracking;
    }
  }
  function remove_consumer(signal, start_index, remove_unowned) {
    const dependencies = signal.d;
    if (dependencies !== null) {
      let i;
      for (i = start_index; i < dependencies.length; i++) {
        const dependency = dependencies[i];
        const consumers = dependency.c;
        let consumers_length = 0;
        if (consumers !== null) {
          consumers_length = consumers.length - 1;
          const index = consumers.indexOf(signal);
          if (index !== -1) {
            if (consumers_length === 0) {
              dependency.c = null;
            } else {
              consumers[index] = consumers[consumers_length];
              consumers.pop();
            }
          }
        }
        if (remove_unowned && consumers_length === 0 && (dependency.f & UNOWNED) !== 0) {
          set_signal_status(dependency, DIRTY);
          remove_consumer(
            /** @type {import('./types.js').ComputationSignal<V>} **/
            dependency,
            0,
            true
          );
        }
      }
    }
  }
  function destroy_references(signal) {
    const references = signal.r;
    signal.r = null;
    if (references !== null) {
      let i;
      for (i = 0; i < references.length; i++) {
        const reference = references[i];
        if ((reference.f & IS_EFFECT) !== 0) {
          destroy_signal(reference);
        } else {
          remove_consumer(reference, 0, true);
          reference.d = null;
        }
      }
    }
  }
  function report_error(block, error) {
    let current_block2 = block;
    if (current_block2 !== null) {
      throw error;
    }
  }
  function execute_effect(signal) {
    if ((signal.f & DESTROYED) !== 0) {
      return;
    }
    const teardown = signal.v;
    const previous_effect = current_effect;
    current_effect = signal;
    try {
      destroy_references(signal);
      if (teardown !== null) {
        teardown();
      }
      const possible_teardown = execute_signal_fn(signal);
      if (typeof possible_teardown === "function") {
        signal.v = possible_teardown;
      }
    } catch (error) {
      const block = signal.b;
      if (block !== null) {
        report_error(block, error);
      } else {
        throw error;
      }
    } finally {
      current_effect = previous_effect;
    }
    const component_context = signal.x;
    if (is_runes(component_context) && // Don't rerun pre effects more than once to accomodate for "$: only runs once" behavior
    (signal.f & PRE_EFFECT) !== 0 && current_queued_pre_and_render_effects.length > 0) {
      flush_local_pre_effects(component_context);
    }
  }
  function infinite_loop_guard() {
    if (flush_count > 100) {
      throw new Error(
        "ERR_SVELTE_TOO_MANY_UPDATES"
      );
    }
    flush_count++;
  }
  function flush_queued_effects(effects) {
    const length = effects.length;
    if (length > 0) {
      infinite_loop_guard();
      let i;
      for (i = 0; i < length; i++) {
        const signal = effects[i];
        const flags = signal.f;
        if ((flags & (DESTROYED | INERT)) === 0) {
          if (is_signal_dirty(signal)) {
            set_signal_status(signal, CLEAN);
            execute_effect(signal);
          } else if ((flags & MAYBE_DIRTY) !== 0) {
            set_signal_status(signal, CLEAN);
          }
        }
      }
      effects.length = 0;
    }
  }
  function process_microtask() {
    is_micro_task_queued = false;
    if (flush_count > 101) {
      return;
    }
    const previous_queued_pre_and_render_effects = current_queued_pre_and_render_effects;
    const previous_queued_effects = current_queued_effects;
    current_queued_pre_and_render_effects = [];
    current_queued_effects = [];
    flush_queued_effects(previous_queued_pre_and_render_effects);
    flush_queued_effects(previous_queued_effects);
    if (!is_micro_task_queued) {
      flush_count = 0;
    }
  }
  function schedule_effect(signal, sync) {
    const flags = signal.f;
    if (sync) {
      execute_effect(signal);
      set_signal_status(signal, CLEAN);
    } else {
      if (current_scheduler_mode === FLUSH_MICROTASK) {
        if (!is_micro_task_queued) {
          is_micro_task_queued = true;
          queueMicrotask(process_microtask);
        }
      }
      if ((flags & EFFECT) !== 0) {
        current_queued_effects.push(signal);
      } else {
        current_queued_pre_and_render_effects.push(signal);
      }
    }
  }
  function process_task() {
    is_task_queued = false;
    const tasks = current_queued_tasks.slice();
    current_queued_tasks = [];
    run_all(tasks);
  }
  function schedule_task(fn) {
    if (!is_task_queued) {
      is_task_queued = true;
      setTimeout(process_task, 0);
    }
    current_queued_tasks.push(fn);
  }
  function flush_local_render_effects() {
    const effects = [];
    for (let i = 0; i < current_queued_pre_and_render_effects.length; i++) {
      const effect2 = current_queued_pre_and_render_effects[i];
      if ((effect2.f & RENDER_EFFECT) !== 0 && effect2.x === current_component_context) {
        effects.push(effect2);
        current_queued_pre_and_render_effects.splice(i, 1);
        i--;
      }
    }
    flush_queued_effects(effects);
  }
  function flush_local_pre_effects(context) {
    const effects = [];
    for (let i = 0; i < current_queued_pre_and_render_effects.length; i++) {
      const effect2 = current_queued_pre_and_render_effects[i];
      if ((effect2.f & PRE_EFFECT) !== 0 && effect2.x === context) {
        effects.push(effect2);
        current_queued_pre_and_render_effects.splice(i, 1);
        i--;
      }
    }
    flush_queued_effects(effects);
  }
  function flushSync(fn) {
    const previous_scheduler_mode = current_scheduler_mode;
    const previous_queued_pre_and_render_effects = current_queued_pre_and_render_effects;
    const previous_queued_effects = current_queued_effects;
    try {
      infinite_loop_guard();
      const pre_and_render_effects = [];
      const effects = [];
      current_scheduler_mode = FLUSH_SYNC;
      current_queued_pre_and_render_effects = pre_and_render_effects;
      current_queued_effects = effects;
      flush_queued_effects(previous_queued_pre_and_render_effects);
      flush_queued_effects(previous_queued_effects);
      if (fn !== void 0) {
        fn();
      }
      if (current_queued_pre_and_render_effects.length > 0 || effects.length > 0) {
        flushSync();
      }
      if (is_task_queued) {
        process_task();
      }
      flush_count = 0;
    } finally {
      current_scheduler_mode = previous_scheduler_mode;
      current_queued_pre_and_render_effects = previous_queued_pre_and_render_effects;
      current_queued_effects = previous_queued_effects;
    }
  }
  async function tick() {
    await Promise.resolve();
    flushSync();
  }
  function update_derived(signal, force_schedule) {
    const previous_updating_derived = updating_derived;
    updating_derived = true;
    const value = execute_signal_fn(signal);
    updating_derived = previous_updating_derived;
    const status = current_skip_consumer || current_effect === null && (signal.f & UNOWNED) !== 0 ? DIRTY : CLEAN;
    set_signal_status(signal, status);
    const equals = (
      /** @type {import('./types.js').EqualsFunctions} */
      signal.e
    );
    if (!equals(value, signal.v)) {
      signal.v = value;
      mark_signal_consumers(signal, DIRTY, force_schedule);
    }
  }
  function store_get(store, store_name, stores) {
    let entry = stores[store_name];
    const is_new = entry === void 0;
    if (is_new) {
      entry = {
        store: null,
        last_value: null,
        value: /* @__PURE__ */ mutable_source(UNINITIALIZED),
        unsubscribe: EMPTY_FUNC
      };
      stores[store_name] = entry;
    }
    if (is_new || entry.store !== store) {
      entry.unsubscribe();
      entry.store = store ?? null;
      entry.unsubscribe = connect_store_to_signal(store, entry.value);
    }
    const value = get(entry.value);
    return value === UNINITIALIZED ? entry.last_value : value;
  }
  function connect_store_to_signal(store, source2) {
    if (store == null) {
      set(source2, void 0);
      return EMPTY_FUNC;
    }
    const run = (v) => {
      ignore_mutation_validation = true;
      set(source2, v);
      ignore_mutation_validation = false;
    };
    return subscribe_to_store(store, run);
  }
  function store_set(store, value) {
    store.set(value);
    return value;
  }
  function unsubscribe_on_destroy(stores) {
    onDestroy(() => {
      let store_name;
      for (store_name in stores) {
        const ref = stores[store_name];
        ref.unsubscribe();
      }
    });
  }
  function get(signal) {
    const flags = signal.f;
    if ((flags & DESTROYED) !== 0) {
      return signal.v;
    }
    if (is_signals_recorded) {
      captured_signals.add(signal);
    }
    if (current_consumer !== null && (current_consumer.f & MANAGED) === 0 && !current_untracking) {
      const unowned = (current_consumer.f & UNOWNED) !== 0;
      const dependencies = current_consumer.d;
      if (current_dependencies === null && dependencies !== null && dependencies[current_dependencies_index] === signal && !(unowned && current_effect !== null)) {
        current_dependencies_index++;
      } else if (current_dependencies === null) {
        current_dependencies = [signal];
      } else if (signal !== current_dependencies[current_dependencies.length - 1]) {
        current_dependencies.push(signal);
      }
      if (current_untracked_writes !== null && current_effect !== null && (current_effect.f & CLEAN) !== 0 && current_untracked_writes.includes(signal)) {
        set_signal_status(current_effect, DIRTY);
        schedule_effect(current_effect, false);
      }
    }
    if ((flags & DERIVED) !== 0 && is_signal_dirty(signal)) {
      {
        update_derived(
          /** @type {import('./types.js').ComputationSignal<V>} **/
          signal,
          false
        );
      }
    }
    return signal.v;
  }
  function set(signal, value) {
    set_signal_value(signal, value);
    return value;
  }
  function set_sync(signal, value) {
    flushSync(() => set(signal, value));
  }
  function invalidate_inner_signals(fn) {
    var previous_is_signals_recorded = is_signals_recorded;
    var previous_captured_signals = captured_signals;
    is_signals_recorded = true;
    captured_signals = /* @__PURE__ */ new Set();
    var captured = captured_signals;
    var signal;
    try {
      untrack(fn);
    } finally {
      is_signals_recorded = previous_is_signals_recorded;
      if (is_signals_recorded) {
        for (signal of captured_signals) {
          previous_captured_signals.add(signal);
        }
      }
      captured_signals = previous_captured_signals;
    }
    for (signal of captured) {
      mutate(
        signal,
        null
        /* doesnt matter */
      );
    }
  }
  function mutate(source2, value) {
    set_signal_value(
      source2,
      untrack(() => get(source2))
    );
    return value;
  }
  function mutate_store(store, expression, new_value) {
    store.set(new_value);
    return expression;
  }
  function mark_subtree_inert(signal, inert) {
    const flags = signal.f;
    const is_already_inert = (flags & INERT) !== 0;
    if (is_already_inert !== inert) {
      signal.f ^= INERT;
      if (!inert && (flags & IS_EFFECT) !== 0 && (flags & CLEAN) === 0) {
        schedule_effect(
          /** @type {import('./types.js').EffectSignal} */
          signal,
          false
        );
      }
    }
    const references = signal.r;
    if (references !== null) {
      let i;
      for (i = 0; i < references.length; i++) {
        mark_subtree_inert(references[i], inert);
      }
    }
  }
  function mark_signal_consumers(signal, to_status, force_schedule) {
    const runes = is_runes(signal.x);
    const consumers = signal.c;
    if (consumers !== null) {
      const length = consumers.length;
      let i;
      for (i = 0; i < length; i++) {
        const consumer = consumers[i];
        const flags = consumer.f;
        const unowned = (flags & UNOWNED) !== 0;
        const dirty = (flags & DIRTY) !== 0;
        if (dirty && !unowned || (!force_schedule || !runes) && consumer === current_effect) {
          continue;
        }
        set_signal_status(consumer, to_status);
        if ((flags & CLEAN) !== 0 || dirty && unowned) {
          if ((consumer.f & IS_EFFECT) !== 0) {
            schedule_effect(
              /** @type {import('./types.js').EffectSignal} */
              consumer,
              false
            );
          } else {
            mark_signal_consumers(consumer, MAYBE_DIRTY, force_schedule);
          }
        }
      }
    }
  }
  function set_signal_value(signal, value) {
    if (!current_untracking && !ignore_mutation_validation && current_consumer !== null && is_runes(signal.x) && (current_consumer.f & DERIVED) !== 0) {
      throw new Error(
        "ERR_SVELTE_UNSAFE_MUTATION"
      );
    }
    if ((signal.f & SOURCE) !== 0 && !/** @type {import('./types.js').EqualsFunctions} */
    signal.e(value, signal.v)) {
      const component_context = signal.x;
      signal.v = value;
      if (is_runes(component_context) && current_effect !== null && current_effect.c === null && (current_effect.f & CLEAN) !== 0) {
        if (current_dependencies !== null && current_dependencies.includes(signal)) {
          set_signal_status(current_effect, DIRTY);
          schedule_effect(current_effect, false);
        } else {
          if (current_untracked_writes === null) {
            current_untracked_writes = [signal];
          } else {
            current_untracked_writes.push(signal);
          }
        }
      }
      mark_signal_consumers(signal, DIRTY, true);
      if (current_effect === null && current_queued_pre_and_render_effects.length === 0) {
        const update_callbacks = component_context == null ? void 0 : component_context.u;
        if (update_callbacks != null) {
          run_all(update_callbacks.b);
          const managed = managed_effect(() => {
            destroy_signal(managed);
            run_all(update_callbacks.a);
          });
        }
      }
    }
  }
  function destroy_signal(signal) {
    const teardown = (
      /** @type {null | (() => void)} */
      signal.v
    );
    const destroy = signal.y;
    const flags = signal.f;
    destroy_references(signal);
    remove_consumer(signal, 0, true);
    signal.i = signal.r = signal.y = signal.x = signal.b = // @ts-expect-error - this is fine, since we're assigning to null to clear out a destroyed signal
    signal.v = signal.d = signal.c = null;
    set_signal_status(signal, DESTROYED);
    if (destroy !== null) {
      if (is_array(destroy)) {
        run_all(destroy);
      } else {
        destroy();
      }
    }
    if (teardown !== null && (flags & IS_EFFECT) !== 0) {
      teardown();
    }
  }
  // @__NO_SIDE_EFFECTS__
  function derived(init2) {
    const is_unowned = current_effect === null;
    const flags = is_unowned ? DERIVED | UNOWNED : DERIVED;
    const signal = (
      /** @type {import('./types.js').ComputationSignal<V>} */
      create_computation_signal(flags | CLEAN, UNINITIALIZED, current_block)
    );
    signal.i = init2;
    signal.x = current_component_context;
    signal.e = default_equals;
    if (!is_unowned) {
      push_reference(
        /** @type {import('./types.js').EffectSignal} */
        current_effect,
        signal
      );
    }
    return signal;
  }
  // @__NO_SIDE_EFFECTS__
  function source(initial_value) {
    const source2 = create_source_signal(SOURCE | CLEAN, initial_value);
    source2.x = current_component_context;
    return source2;
  }
  // @__NO_SIDE_EFFECTS__
  function mutable_source(initial_value) {
    const s = /* @__PURE__ */ source(initial_value);
    s.e = safe_equal;
    return s;
  }
  function untrack(fn) {
    const previous_untracking = current_untracking;
    try {
      current_untracking = true;
      return fn();
    } finally {
      current_untracking = previous_untracking;
    }
  }
  function internal_create_effect(type, init2, sync, block, schedule) {
    const signal = create_computation_signal(type | DIRTY, null, block);
    signal.i = init2;
    signal.x = current_component_context;
    if (schedule) {
      schedule_effect(signal, sync);
    }
    if (current_effect !== null && (type & MANAGED) === 0) {
      push_reference(current_effect, signal);
    }
    return signal;
  }
  function effect_active() {
    return current_effect ? (current_effect.f & MANAGED) === 0 : false;
  }
  function user_effect(init2) {
    if (current_effect === null) {
      throw new Error(
        "ERR_SVELTE_ORPHAN_EFFECT"
      );
    }
    const apply_component_effect_heuristics = current_effect.f & RENDER_EFFECT && current_component_context !== null && !current_component_context.m;
    const effect2 = internal_create_effect(
      EFFECT,
      init2,
      false,
      current_block,
      !apply_component_effect_heuristics
    );
    if (apply_component_effect_heuristics) {
      let effects = (
        /** @type {import('./types.js').ComponentContext} */
        current_component_context.e
      );
      if (effects === null) {
        effects = /** @type {import('./types.js').ComponentContext} */
        current_component_context.e = [];
      }
      effects.push(effect2);
    }
    return effect2;
  }
  function user_root_effect(init2) {
    const effect2 = managed_render_effect(init2);
    return () => {
      destroy_signal(effect2);
    };
  }
  function effect(init2) {
    return internal_create_effect(EFFECT, init2, false, current_block, true);
  }
  function managed_effect(init2) {
    return internal_create_effect(EFFECT | MANAGED, init2, false, current_block, true);
  }
  function managed_pre_effect(init2, sync) {
    return internal_create_effect(PRE_EFFECT | MANAGED, init2, sync, current_block, true);
  }
  function pre_effect(init2) {
    if (current_effect === null) {
      throw new Error(
        "ERR_SVELTE_ORPHAN_EFFECT"
      );
    }
    const sync = current_effect !== null && (current_effect.f & RENDER_EFFECT) !== 0;
    return internal_create_effect(
      PRE_EFFECT,
      () => {
        const val = init2();
        flush_local_render_effects();
        return val;
      },
      sync,
      current_block,
      true
    );
  }
  function invalidate_effect(init2) {
    return internal_create_effect(PRE_EFFECT, init2, true, current_block, true);
  }
  function render_effect(init2, block = current_block, managed = false, sync = true) {
    let flags = RENDER_EFFECT;
    if (managed) {
      flags |= MANAGED;
    }
    return internal_create_effect(
      flags,
      /** @type {any} */
      init2,
      sync,
      block,
      true
    );
  }
  function managed_render_effect(init2, block = current_block, sync = true) {
    const flags = RENDER_EFFECT | MANAGED;
    return internal_create_effect(
      flags,
      /** @type {any} */
      init2,
      sync,
      block,
      true
    );
  }
  function push_destroy_fn(signal, destroy_fn) {
    let destroy = signal.y;
    if (destroy === null) {
      signal.y = destroy_fn;
    } else if (is_array(destroy)) {
      destroy.push(destroy_fn);
    } else {
      signal.y = [destroy, destroy_fn];
    }
  }
  const STATUS_MASK = ~(DIRTY | MAYBE_DIRTY | CLEAN);
  function set_signal_status(signal, status) {
    signal.f = signal.f & STATUS_MASK | status;
  }
  function is_signal(val) {
    return typeof val === "object" && val !== null && typeof /** @type {import('./types.js').Signal<V>} */
    val.f === "number";
  }
  function is_lazy_property(val) {
    return typeof val === "object" && val !== null && /** @type {import('./types.js').LazyProperty<O, P>} */
    val.t === LAZY_PROPERTY;
  }
  function prop(props, key2, flags, initial) {
    var _a;
    var immutable = (flags & PROPS_IS_IMMUTABLE) !== 0;
    var setter = (_a = get_descriptor(props, key2)) == null ? void 0 : _a.set;
    var prop_value = (
      /** @type {V} */
      props[key2]
    );
    if (prop_value === void 0 && initial !== void 0) {
      if ((flags & PROPS_IS_LAZY_INITIAL) !== 0)
        initial = initial();
      prop_value = /** @type {V} */
      initial;
      if (setter)
        setter(prop_value);
    }
    var getter = () => {
      var value = (
        /** @type {V} */
        props[key2]
      );
      if (value !== void 0)
        initial = void 0;
      return value === void 0 ? (
        /** @type {V} */
        initial
      ) : value;
    };
    if ((flags & PROPS_IS_UPDATED) === 0) {
      return getter;
    }
    if (setter) {
      return function(value) {
        if (arguments.length === 1) {
          setter(value);
          return value;
        } else {
          return getter();
        }
      };
    }
    var from_child = false;
    var was_from_child = false;
    var inner_current_value = /* @__PURE__ */ mutable_source(prop_value);
    var current_value = /* @__PURE__ */ derived(() => {
      var parent_value = getter();
      var child_value = get(inner_current_value);
      if (from_child) {
        from_child = false;
        was_from_child = true;
        return child_value;
      }
      was_from_child = false;
      return inner_current_value.v = parent_value;
    });
    if (!immutable)
      current_value.e = safe_equal;
    return function(value, mutation = false) {
      var current = get(current_value);
      if (is_signals_recorded) {
        from_child = was_from_child;
        getter();
        get(inner_current_value);
      }
      if (arguments.length > 0) {
        if (mutation || (immutable ? value !== current : safe_not_equal(value, current))) {
          from_child = true;
          set(inner_current_value, mutation ? current : value);
          get(current_value);
        }
        return value;
      }
      return current;
    };
  }
  function safe_not_equal(a, b) {
    return a != a ? (
      // eslint-disable-next-line eqeqeq
      b == b
    ) : a !== b || a !== null && typeof a === "object" || typeof a === "function";
  }
  function safe_equal(a, b) {
    return !safe_not_equal(a, b);
  }
  function bubble_event($$props, event2) {
    var _a;
    var events = (
      /** @type {Record<string, Function[] | Function>} */
      (_a = $$props.$$events) == null ? void 0 : _a[event2.type]
    );
    var callbacks = is_array(events) ? events.slice() : events == null ? [] : [events];
    for (var fn of callbacks) {
      fn.call(this, event2);
    }
  }
  function update(signal, d = 1) {
    const value = get(signal);
    set_signal_value(signal, value + d);
    return value;
  }
  function update_prop(fn, d = 1) {
    const value = fn();
    fn(value + d);
    return value;
  }
  function update_store(store, store_value, d = 1) {
    store.set(store_value + d);
    return store_value;
  }
  function update_pre(signal, d = 1) {
    const value = get(signal) + d;
    set_signal_value(signal, value);
    return value;
  }
  function update_pre_prop(fn, d = 1) {
    const value = fn() + d;
    fn(value);
    return value;
  }
  function update_pre_store(store, store_value, d = 1) {
    const value = store_value + d;
    store.set(value);
    return value;
  }
  function reactive_import(fn) {
    const s = /* @__PURE__ */ source(0);
    return function() {
      if (arguments.length === 1) {
        set(s, get(s) + 1);
        return arguments[0];
      } else {
        get(s);
        return fn();
      }
    };
  }
  function exclude_from_object(obj, keys) {
    obj = { ...obj };
    let key2;
    for (key2 of keys) {
      delete obj[key2];
    }
    return obj;
  }
  function value_or_fallback(value, fallback) {
    return value === void 0 ? fallback : value;
  }
  function onDestroy(fn) {
    {
      user_effect(() => () => untrack(fn));
    }
  }
  function push(props, runes = false) {
    current_component_context = {
      // accessors
      a: null,
      // context
      c: null,
      // effects
      e: null,
      // mounted
      m: false,
      // parent
      p: current_component_context,
      // props
      s: props,
      // runes
      r: runes,
      // update_callbacks
      u: null
    };
  }
  function pop(accessors) {
    const context_stack_item = current_component_context;
    if (context_stack_item !== null) {
      if (accessors !== void 0) {
        context_stack_item.a = accessors;
      }
      const effects = context_stack_item.e;
      if (effects !== null) {
        context_stack_item.e = null;
        for (let i = 0; i < effects.length; i++) {
          schedule_effect(effects[i], false);
        }
      }
      current_component_context = context_stack_item.p;
      context_stack_item.m = true;
    }
  }
  function deep_read(value, visited = /* @__PURE__ */ new Set()) {
    if (typeof value === "object" && value !== null && !visited.has(value)) {
      visited.add(value);
      for (let key2 in value) {
        deep_read(value[key2], visited);
      }
      const proto = Object.getPrototypeOf(value);
      if (proto !== Object.prototype && proto !== Array.prototype && proto !== Map.prototype && proto !== Set.prototype && proto !== Date.prototype) {
        const descriptors = get_descriptors(proto);
        for (let key2 in descriptors) {
          const get2 = descriptors[key2].get;
          if (get2) {
            get2.call(value);
          }
        }
      }
    }
  }
  let warned_inspect_changed = false;
  function inspect(get_value, inspect2 = console.log) {
    let initial = true;
    pre_effect(() => {
      const fn = () => {
        const value2 = get_value().map(unstate);
        if (value2.length === 2 && typeof value2[1] === "function" && !warned_inspect_changed) {
          console.warn(
            "$inspect() API has changed. See https://svelte-5-preview.vercel.app/docs/runes#$inspect for more information."
          );
          warned_inspect_changed = true;
        }
        inspect2(initial ? "init" : "update", ...value2);
      };
      const value = get_value();
      deep_read(value);
      const signals = inspect_captured_signals.slice();
      inspect_captured_signals = [];
      if (initial) {
        fn();
        initial = false;
      }
      return () => {
        for (const s of signals) {
          s.inspect.delete(fn);
        }
      };
    });
  }
  function lazy_property(o, p) {
    return {
      o,
      p,
      t: LAZY_PROPERTY
    };
  }
  function unwrap(value) {
    if (is_signal(value)) {
      return get(value);
    }
    if (is_lazy_property(value)) {
      return value.o[value.p];
    }
    return value;
  }
  const ROOT_BLOCK = 0;
  const IF_BLOCK = 1;
  const EACH_BLOCK = 2;
  const EACH_ITEM_BLOCK = 3;
  const AWAIT_BLOCK = 4;
  const KEY_BLOCK = 5;
  const HEAD_BLOCK = 6;
  const DYNAMIC_COMPONENT_BLOCK = 7;
  const DYNAMIC_ELEMENT_BLOCK = 8;
  const SNIPPET_BLOCK = 9;
  function create_root_block(intro) {
    return {
      // dom
      d: null,
      // effect
      e: null,
      // intro
      i: intro,
      // parent
      p: null,
      // transition
      r: null,
      // type
      t: ROOT_BLOCK
    };
  }
  function create_if_block() {
    return {
      // alternate transitions
      a: null,
      // alternate effect
      ae: null,
      // consequent transitions
      c: null,
      // consequent effect
      ce: null,
      // dom
      d: null,
      // effect
      e: null,
      // parent
      p: (
        /** @type {import('./types.js').Block} */
        current_block
      ),
      // transition
      r: null,
      // type
      t: IF_BLOCK,
      // value
      v: false
    };
  }
  function create_key_block() {
    return {
      // dom
      d: null,
      // effect
      e: null,
      // parent
      p: (
        /** @type {import('./types.js').Block} */
        current_block
      ),
      // transition
      r: null,
      // type
      t: KEY_BLOCK
    };
  }
  function create_head_block() {
    return {
      // dom
      d: null,
      // effect
      e: null,
      // parent
      p: (
        /** @type {import('./types.js').Block} */
        current_block
      ),
      // transition
      r: null,
      // type
      t: HEAD_BLOCK
    };
  }
  function create_dynamic_element_block() {
    return {
      // dom
      d: null,
      // effect
      e: null,
      // parent
      p: (
        /** @type {import('./types.js').Block} */
        current_block
      ),
      // transition
      r: null,
      // type
      t: DYNAMIC_ELEMENT_BLOCK
    };
  }
  function create_dynamic_component_block() {
    return {
      // dom
      d: null,
      // effect
      e: null,
      // parent
      p: (
        /** @type {import('./types.js').Block} */
        current_block
      ),
      // transition
      r: null,
      // type
      t: DYNAMIC_COMPONENT_BLOCK
    };
  }
  function create_await_block() {
    return {
      // dom
      d: null,
      // effect
      e: null,
      // parent
      p: (
        /** @type {import('./types.js').Block} */
        current_block
      ),
      // pending
      n: true,
      // transition
      r: null,
      // type
      t: AWAIT_BLOCK
    };
  }
  function create_each_block(flags, anchor) {
    return {
      // anchor
      a: anchor,
      // dom
      d: null,
      // flags
      f: flags,
      // items
      v: [],
      // effect
      e: null,
      p: (
        /** @type {import('./types.js').Block} */
        current_block
      ),
      // transition
      r: null,
      // transitions
      s: [],
      // type
      t: EACH_BLOCK
    };
  }
  function create_each_item_block(item, index, key2) {
    return {
      // animate transition
      a: null,
      // dom
      d: null,
      // effect
      e: null,
      // index
      i: index,
      // key
      k: key2,
      // item
      v: item,
      // parent
      p: (
        /** @type {import('./types.js').EachBlock} */
        current_block
      ),
      // transition
      r: null,
      // transitions
      s: null,
      // type
      t: EACH_ITEM_BLOCK
    };
  }
  function create_snippet_block() {
    return {
      // dom
      d: null,
      // parent
      p: (
        /** @type {import('./types.js').Block} */
        current_block
      ),
      // effect
      e: null,
      // transition
      r: null,
      // type
      t: SNIPPET_BLOCK
    };
  }
  let current_hydration_fragment = null;
  function set_current_hydration_fragment(fragment) {
    current_hydration_fragment = fragment;
  }
  function get_hydration_fragment(node) {
    const fragment = [];
    let current_node = node;
    let target_depth = null;
    while (current_node !== null) {
      const node_type = current_node.nodeType;
      const next_sibling = current_node.nextSibling;
      if (node_type === 8) {
        const data = (
          /** @type {Comment} */
          current_node.data
        );
        if (data.startsWith("ssr:")) {
          const depth = data.slice(4);
          if (target_depth === null) {
            target_depth = depth;
          } else if (depth === target_depth) {
            return fragment;
          } else {
            fragment.push(
              /** @type {Text | Comment | Element} */
              current_node
            );
          }
          current_node = next_sibling;
          continue;
        }
      }
      if (target_depth !== null) {
        fragment.push(
          /** @type {Text | Comment | Element} */
          current_node
        );
      }
      current_node = next_sibling;
    }
    return null;
  }
  function hydrate_block_anchor(anchor_node, is_controlled) {
    let target_node = anchor_node;
    if (current_hydration_fragment !== null) {
      if (is_controlled) {
        target_node = /** @type {Node} */
        target_node.firstChild;
      }
      if (target_node.nodeType === 8) {
        let fragment = target_node.$$fragment;
        if (fragment === void 0) {
          fragment = get_hydration_fragment(target_node);
        } else {
          schedule_task(() => {
            target_node.$$fragment = void 0;
          });
        }
        set_current_hydration_fragment(fragment);
      } else {
        const first_child = (
          /** @type {Element | null} */
          target_node.firstChild
        );
        set_current_hydration_fragment(first_child === null ? [] : [first_child]);
      }
    }
  }
  var node_prototype;
  var element_prototype;
  var text_prototype;
  var map_prototype;
  var append_child_method;
  var clone_node_method;
  var map_set_method;
  var map_get_method;
  var first_child_get;
  var next_sibling_get;
  var text_content_set;
  var class_name_set;
  var $window;
  var $document;
  function init_operations() {
    if (node_prototype !== void 0) {
      return;
    }
    node_prototype = Node.prototype;
    element_prototype = Element.prototype;
    text_prototype = Text.prototype;
    map_prototype = Map.prototype;
    append_child_method = node_prototype.appendChild;
    clone_node_method = node_prototype.cloneNode;
    map_set_method = map_prototype.set;
    map_get_method = map_prototype.get;
    map_prototype.delete;
    $window = window;
    $document = document;
    element_prototype.__click = void 0;
    text_prototype.__nodeValue = " ";
    element_prototype.__className = "";
    first_child_get = /** @type {(this: Node) => ChildNode | null} */
    // @ts-ignore
    get_descriptor(node_prototype, "firstChild").get;
    next_sibling_get = /** @type {(this: Node) => ChildNode | null} */
    // @ts-ignore
    get_descriptor(node_prototype, "nextSibling").get;
    text_content_set = /** @type {(this: Node, text: string ) => void} */
    // @ts-ignore
    get_descriptor(node_prototype, "textContent").set;
    class_name_set = /** @type {(this: Element, class_name: string) => void} */
    // @ts-ignore
    get_descriptor(element_prototype, "className").set;
  }
  function append_child(element2, child2) {
    append_child_method.call(element2, child2);
  }
  function map_set(map, key2, value) {
    map_set_method.call(map, key2, value);
  }
  function map_get(map, key2) {
    return map_get_method.call(map, key2);
  }
  // @__NO_SIDE_EFFECTS__
  function clone_node(node, deep) {
    return (
      /** @type {N} */
      clone_node_method.call(node, deep)
    );
  }
  // @__NO_SIDE_EFFECTS__
  function child(node) {
    const child2 = first_child_get.call(node);
    if (current_hydration_fragment !== null) {
      if (child2 === null) {
        const text2 = document.createTextNode("");
        node.appendChild(text2);
        return text2;
      } else {
        return capture_fragment_from_node(child2);
      }
    }
    return child2;
  }
  // @__NO_SIDE_EFFECTS__
  function child_frag(node) {
    if (current_hydration_fragment !== null) {
      const first_node = (
        /** @type {Node[]} */
        node[0]
      );
      if (current_hydration_fragment !== null && first_node !== null) {
        return capture_fragment_from_node(first_node);
      }
      return first_node;
    }
    return first_child_get.call(
      /** @type {Node} */
      node
    );
  }
  // @__NO_SIDE_EFFECTS__
  function sibling(node) {
    const next_sibling = next_sibling_get.call(node);
    if (current_hydration_fragment !== null && next_sibling !== null) {
      return capture_fragment_from_node(next_sibling);
    }
    return next_sibling;
  }
  function set_class_name(node, class_name2) {
    class_name_set.call(node, class_name2);
  }
  function clear_text_content(node) {
    text_content_set.call(node, "");
  }
  // @__NO_SIDE_EFFECTS__
  function create_element(name) {
    return document.createElement(name);
  }
  function capture_fragment_from_node(node) {
    if (node.nodeType === 8 && /** @type {Comment} */
    node.data.startsWith("ssr:") && /** @type {Array<Element | Text | Comment>} */
    current_hydration_fragment.at(-1) !== node) {
      const fragment = (
        /** @type {Array<Element | Text | Comment>} */
        get_hydration_fragment(node)
      );
      const last_child = fragment.at(-1) || node;
      const target = (
        /** @type {Node} */
        last_child.nextSibling
      );
      target.$$fragment = fragment;
      return target;
    }
    return node;
  }
  function create_fragment_from_html(html2) {
    var elem = document.createElement("template");
    elem.innerHTML = html2;
    return elem.content;
  }
  function insert(current, parent_element, sibling2) {
    if (is_array(current)) {
      var i = 0;
      var node;
      for (; i < current.length; i++) {
        node = current[i];
        if (sibling2 === null) {
          append_child(
            /** @type {Element} */
            parent_element,
            /** @type {Node} */
            node
          );
        } else {
          sibling2.before(
            /** @type {Node} */
            node
          );
        }
      }
      return current[0];
    } else if (current !== null) {
      if (sibling2 === null) {
        append_child(
          /** @type {Element} */
          parent_element,
          /** @type {Node} */
          current
        );
      } else {
        sibling2.before(
          /** @type {Node} */
          current
        );
      }
    }
    return (
      /** @type {Text | Element | Comment} */
      current
    );
  }
  function remove(current) {
    var first_node = current;
    if (is_array(current)) {
      var i = 0;
      var node;
      for (; i < current.length; i++) {
        node = current[i];
        if (i === 0) {
          first_node = node;
        }
        if (node.isConnected) {
          node.remove();
        }
      }
    } else if (current.isConnected) {
      current.remove();
    }
    return (
      /** @type {Element | Comment | Text} */
      first_node
    );
  }
  function reconcile_html(dom, value, svg) {
    hydrate_block_anchor(dom);
    if (current_hydration_fragment !== null) {
      return current_hydration_fragment;
    }
    var html2 = value + "";
    var target = dom;
    var frag_nodes;
    if (svg) {
      html2 = `<svg>${html2}</svg>`;
    }
    var content = create_fragment_from_html(html2);
    if (svg) {
      content = /** @type {DocumentFragment} */
      /** @type {unknown} */
      content.firstChild;
    }
    var clone = content.cloneNode(true);
    frag_nodes = Array.from(clone.childNodes);
    frag_nodes.forEach((node) => {
      target.before(node);
    });
    return (
      /** @type {Array<Text | Comment | Element>} */
      frag_nodes
    );
  }
  const raf = {
    tick: (
      /** @param {any} _ */
      (_) => requestAnimationFrame(_)
    ),
    now: () => performance.now()
  };
  const active_tick_animations = /* @__PURE__ */ new Set();
  const DELAY_NEXT_TICK = Number.MIN_SAFE_INTEGER;
  let active_tick_ref = void 0;
  function custom_event(type, detail, { bubbles = false, cancelable = false } = {}) {
    const e = document.createEvent("CustomEvent");
    e.initCustomEvent(type, bubbles, cancelable, detail);
    return e;
  }
  function dispatch_event(dom, type) {
    dom.dispatchEvent(custom_event(type));
  }
  function css_style_from_camel_case(style2) {
    const parts = style2.split("-");
    if (parts.length === 1)
      return parts[0];
    return parts[0] + parts.slice(1).map(
      /** @param {any} word */
      (word) => word[0].toUpperCase() + word.slice(1)
    ).join("");
  }
  function css_to_keyframe(css) {
    const keyframe = {};
    const parts = css.split(";");
    for (const part of parts) {
      const [property, value] = part.split(":");
      if (!property || value === void 0)
        break;
      const formatted_property = css_style_from_camel_case(property.trim());
      keyframe[formatted_property] = value.trim();
    }
    return keyframe;
  }
  class TickAnimation {
    /**
     * @param {(t: number, u: number) => string} tick_fn
     * @param {number} duration
     * @param {number} delay
     * @param {boolean} out
     */
    constructor(tick_fn, duration, delay, out2) {
      __privateAdd(this, _reverse);
      /** @type {null | (() => void)} */
      __publicField(this, "onfinish");
      /** @type {(t: number, u: number) => string} */
      __privateAdd(this, _tick_fn, void 0);
      /** @type {number} */
      __privateAdd(this, _duration, void 0);
      /** @type {number} */
      __privateAdd(this, _current, void 0);
      /** @type {number} */
      __privateAdd(this, _delay, void 0);
      /** @type {number} */
      __privateAdd(this, _previous, void 0);
      /** @type {boolean} */
      __publicField(this, "paused");
      /** @type {boolean} */
      __privateAdd(this, _reversed, void 0);
      /** @type {number} */
      __privateAdd(this, _delay_current, void 0);
      /** @type {boolean} */
      __privateAdd(this, _delayed_reverse, void 0);
      __privateSet(this, _duration, duration);
      __privateSet(this, _delay, delay);
      this.paused = false;
      __privateSet(this, _tick_fn, tick_fn);
      __privateSet(this, _reversed, out2);
      __privateSet(this, _delay_current, delay);
      __privateSet(this, _current, out2 ? duration : 0);
      __privateSet(this, _previous, 0);
      __privateSet(this, _delayed_reverse, false);
      this.onfinish = null;
      if (__privateGet(this, _delay)) {
        if (!out2) {
          __privateGet(this, _tick_fn).call(this, 0, 1);
        }
      }
    }
    pause() {
      this.paused = true;
    }
    play() {
      this.paused = false;
      if (!active_tick_animations.has(this)) {
        __privateSet(this, _previous, raf.now());
        if (active_tick_ref === void 0) {
          active_tick_ref = raf.tick(handle_raf);
        }
        active_tick_animations.add(this);
      }
    }
    reverse() {
      if (__privateGet(this, _delay) === 0) {
        __privateMethod(this, _reverse, reverse_fn).call(this);
      } else {
        __privateSet(this, _delay_current, __privateGet(this, _delay));
        __privateSet(this, _delayed_reverse, true);
      }
    }
    cancel() {
      active_tick_animations.delete(this);
      const current = __privateGet(this, _current) / __privateGet(this, _duration);
      if (current > 0 && current < 1) {
        const t = __privateGet(this, _reversed) ? 1 : 0;
        __privateGet(this, _tick_fn).call(this, t, 1 - t);
      }
    }
    finish() {
      active_tick_animations.delete(this);
      if (this.onfinish) {
        this.onfinish();
      }
    }
    /** @param {number} time */
    _update(time) {
      let diff = time - __privateGet(this, _previous);
      __privateSet(this, _previous, time);
      if (__privateGet(this, _delay_current) !== 0) {
        const is_delayed = __privateGet(this, _delay_current) === DELAY_NEXT_TICK;
        let cancel = !__privateGet(this, _delayed_reverse);
        __privateSet(this, _delay_current, __privateGet(this, _delay_current) - diff);
        if (__privateGet(this, _delay_current) < 0 || is_delayed || __privateGet(this, _delay_current) === 0 && __privateGet(this, _reversed)) {
          const delay_diff = is_delayed ? 0 : -__privateGet(this, _delay_current);
          __privateSet(this, _delay_current, 0);
          if (__privateGet(this, _delayed_reverse)) {
            __privateSet(this, _delayed_reverse, false);
            __privateMethod(this, _reverse, reverse_fn).call(this);
          } else if (delay_diff !== 0 || __privateGet(this, _reversed)) {
            diff = delay_diff;
          }
          cancel = false;
        } else if (__privateGet(this, _delay_current) === 0) {
          __privateSet(this, _delay_current, DELAY_NEXT_TICK);
        }
        if (cancel) {
          return;
        }
      }
      __privateSet(this, _current, __privateGet(this, _current) + (__privateGet(this, _reversed) ? -diff : diff));
      let t = __privateGet(this, _current) / __privateGet(this, _duration);
      if (t < 0) {
        t = 0;
      } else if (t > 1) {
        t = 1;
      }
      if (__privateGet(this, _reversed) && t <= 0 || !__privateGet(this, _reversed) && t >= 1) {
        t = __privateGet(this, _reversed) ? 0 : 1;
        if (__privateGet(this, _delay_current) === 0) {
          active_tick_animations.delete(this);
          if (this.onfinish) {
            this.paused = true;
            this.onfinish();
          }
        }
      }
      __privateGet(this, _tick_fn).call(this, t, 1 - t);
    }
  }
  _tick_fn = new WeakMap();
  _duration = new WeakMap();
  _current = new WeakMap();
  _delay = new WeakMap();
  _previous = new WeakMap();
  _reversed = new WeakMap();
  _delay_current = new WeakMap();
  _delayed_reverse = new WeakMap();
  _reverse = new WeakSet();
  reverse_fn = function() {
    __privateSet(this, _reversed, !__privateGet(this, _reversed));
    if (this.paused) {
      if (__privateGet(this, _current) === 0) {
        __privateSet(this, _current, __privateGet(this, _duration));
      }
      this.play();
    }
  };
  function handle_raf(time) {
    for (const animation of active_tick_animations) {
      if (!animation.paused) {
        animation._update(time);
      }
    }
    if (active_tick_animations.size !== 0) {
      active_tick_ref = raf.tick(handle_raf);
    } else {
      active_tick_ref = void 0;
    }
  }
  function create_transition(dom, init2, direction, effect2) {
    let curr_direction = "in";
    let subs = [];
    let animation = null;
    let cancelled = false;
    const create_animation = () => {
      let payload = (
        /** @type {import('./types.js').TransitionPayload} */
        transition2.p
      );
      if (typeof payload === "function") {
        payload = payload({ direction: curr_direction });
      }
      const duration = payload.duration ?? 300;
      const delay = payload.delay ?? 0;
      const css_fn = payload.css;
      const tick_fn = payload.tick;
      const linear = (t) => t;
      const easing_fn = payload.easing || linear;
      const keyframes = [];
      if (typeof tick_fn === "function") {
        animation = new TickAnimation(tick_fn, duration, delay, direction === "out");
      } else {
        if (typeof css_fn === "function") {
          const frame_time = 16.666;
          const max_duration = Math.max(duration, frame_time);
          for (let i = 0; i <= max_duration; i += frame_time) {
            let time;
            if (i + frame_time > max_duration) {
              time = 1;
            } else if (i === 0) {
              time = 0;
            } else {
              time = i / max_duration;
            }
            const t = easing_fn(time);
            keyframes.push(css_to_keyframe(css_fn(t, 1 - t)));
          }
          if (direction === "out") {
            keyframes.reverse();
          }
        }
        animation = dom.animate(keyframes, {
          duration,
          endDelay: delay,
          delay,
          fill: "both"
        });
      }
      animation.pause();
      animation.onfinish = () => {
        const is_outro = curr_direction === "out";
        animation.cancel();
        if (is_outro) {
          run_all(subs);
          subs = [];
        }
        dispatch_event(dom, is_outro ? "outroend" : "introend");
      };
    };
    const transition2 = {
      e: effect2,
      i: init2,
      // payload
      p: null,
      // finished
      /** @param {() => void} fn */
      f(fn) {
        subs.push(fn);
      },
      in() {
        const needs_reverse = curr_direction !== "in";
        curr_direction = "in";
        if (animation === null || cancelled) {
          cancelled = false;
          create_animation();
        }
        dispatch_event(dom, "introstart");
        if (needs_reverse) {
          animation.reverse();
        }
        animation.play();
      },
      // out
      o() {
        const needs_reverse = direction === "both" && curr_direction !== "out";
        curr_direction = "out";
        if (animation === null || cancelled) {
          cancelled = false;
          create_animation();
        }
        dispatch_event(dom, "outrostart");
        if (needs_reverse) {
          animation.reverse();
        } else {
          animation.play();
        }
      },
      // cancel
      c() {
        if (animation !== null) {
          animation.cancel();
        }
        cancelled = true;
      },
      // cleanup
      x() {
        run_all(subs);
        subs = [];
      },
      r: direction,
      d: dom
    };
    return transition2;
  }
  function is_transition_block(block) {
    const type = block.t;
    return type === IF_BLOCK || type === EACH_ITEM_BLOCK || type === KEY_BLOCK || type === AWAIT_BLOCK || type === DYNAMIC_COMPONENT_BLOCK || type === EACH_BLOCK && block.v.length === 0;
  }
  function bind_transition(dom, get_transition_fn, props_fn, direction, global) {
    const transition_effect = (
      /** @type {import('./types.js').EffectSignal} */
      current_effect
    );
    const block = current_block;
    const props = props_fn === null ? {} : props_fn();
    let can_show_intro_on_mount = true;
    let can_apply_lazy_transitions = false;
    let transition_block = block;
    while (transition_block !== null) {
      if (is_transition_block(transition_block)) {
        if (transition_block.t === EACH_ITEM_BLOCK) {
          transition_block.r = each_item_transition;
          transition_block.a = each_item_animate;
          transition_block = transition_block.p;
        } else if (transition_block.t === AWAIT_BLOCK && transition_block.n) {
          can_show_intro_on_mount = false;
        } else if (transition_block.t === IF_BLOCK) {
          transition_block.r = if_block_transition;
        }
        if (!can_apply_lazy_transitions && can_show_intro_on_mount) {
          can_show_intro_on_mount = transition_block.e === null;
        }
        if (!can_show_intro_on_mount || !global) {
          can_apply_lazy_transitions = true;
        }
      } else if (!can_apply_lazy_transitions && transition_block.t === ROOT_BLOCK && (transition_block.e !== null || transition_block.i)) {
        can_show_intro_on_mount = false;
      }
      transition_block = transition_block.p;
    }
    let transition2;
    effect(() => {
      if (transition2 !== void 0) {
        transition2.x();
      }
      const transition_fn = get_transition_fn();
      const init2 = (from) => untrack(
        () => direction === "key" ? (
          /** @type {import('./types.js').AnimateFn<any>} */
          transition_fn(
            dom,
            { from: (
              /** @type {DOMRect} */
              from
            ), to: dom.getBoundingClientRect() },
            props,
            {}
          )
        ) : (
          /** @type {import('./types.js').TransitionFn<any>} */
          transition_fn(dom, props, {
            direction
          })
        )
      );
      transition2 = create_transition(dom, init2, direction, transition_effect);
      const is_intro = direction === "in";
      const show_intro = !can_show_intro_on_mount && (is_intro || direction === "both");
      if (show_intro) {
        transition2.p = transition2.i();
      }
      const effect2 = managed_pre_effect(() => {
        destroy_signal(effect2);
        dom.inert = false;
        if (show_intro) {
          transition2.in();
        }
        let transition_block2 = block;
        while (!is_intro && transition_block2 !== null) {
          const parent = transition_block2.p;
          if (is_transition_block(transition_block2)) {
            if (transition_block2.r !== null) {
              transition_block2.r(transition2);
            }
            if (parent === null || !global && (transition_block2.t !== IF_BLOCK || parent.t !== IF_BLOCK || parent.v)) {
              break;
            }
          }
          transition_block2 = parent;
        }
      }, false);
    });
    if (direction === "key") {
      effect(() => {
        return () => {
          transition2.x();
        };
      });
    }
  }
  function trigger_transitions(transitions, target_direction, from) {
    const outros = [];
    for (const transition2 of transitions) {
      const direction = transition2.r;
      if (target_direction === "in") {
        if (direction === "in" || direction === "both") {
          transition2.in();
        } else {
          transition2.c();
        }
        transition2.d.inert = false;
        mark_subtree_inert(transition2.e, false);
      } else if (target_direction === "key") {
        if (direction === "key") {
          transition2.p = transition2.i(
            /** @type {DOMRect} */
            from
          );
          transition2.in();
        }
      } else {
        if (direction === "out" || direction === "both") {
          transition2.p = transition2.i();
          outros.push(transition2.o);
        }
        transition2.d.inert = true;
        mark_subtree_inert(transition2.e, true);
      }
    }
    if (outros.length > 0) {
      const e = managed_pre_effect(() => {
        destroy_signal(e);
        const e2 = managed_effect(() => {
          destroy_signal(e2);
          run_all(outros);
        });
      }, false);
    }
  }
  function if_block_transition(transition2) {
    const block = this;
    if (block.v) {
      let consequent_transitions = block.c;
      if (consequent_transitions === null) {
        consequent_transitions = block.c = /* @__PURE__ */ new Set();
      }
      consequent_transitions.add(transition2);
      transition2.f(() => {
        const c = (
          /** @type {Set<import('./types.js').Transition>} */
          consequent_transitions
        );
        c.delete(transition2);
        if (c.size === 0) {
          execute_effect(
            /** @type {import('./types.js').EffectSignal} */
            block.ce
          );
        }
      });
    } else {
      let alternate_transitions = block.a;
      if (alternate_transitions === null) {
        alternate_transitions = block.a = /* @__PURE__ */ new Set();
      }
      alternate_transitions.add(transition2);
      transition2.f(() => {
        const a = (
          /** @type {Set<import('./types.js').Transition>} */
          alternate_transitions
        );
        a.delete(transition2);
        if (a.size === 0) {
          execute_effect(
            /** @type {import('./types.js').EffectSignal} */
            block.ae
          );
        }
      });
    }
  }
  function each_item_transition(transition2) {
    const block = this;
    const each_block = block.p;
    const is_controlled = (each_block.f & EACH_IS_CONTROLLED) !== 0;
    if (is_controlled) {
      const anchor = empty();
      each_block.f ^= EACH_IS_CONTROLLED;
      append_child(
        /** @type {Element} */
        each_block.a,
        anchor
      );
      each_block.a = anchor;
    }
    if (transition2.r === "key" && (each_block.f & EACH_IS_ANIMATED) === 0) {
      each_block.f |= EACH_IS_ANIMATED;
    }
    let transitions = block.s;
    if (transitions === null) {
      block.s = transitions = /* @__PURE__ */ new Set();
    }
    transition2.f(() => {
      if (transitions !== null) {
        transitions.delete(transition2);
        if (transition2.r !== "key") {
          for (let other of transitions) {
            if (other.r === "key" || other.r === "in") {
              transitions.delete(other);
            }
          }
          if (transitions.size === 0) {
            block.s = null;
            destroy_each_item_block(block, null, true);
          }
        }
      }
    });
    transitions.add(transition2);
  }
  function each_item_animate(block, transitions, index, index_is_reactive) {
    let prev_index = block.i;
    if (index_is_reactive) {
      prev_index = /** @type {import('./types.js').Signal<number>} */
      prev_index.v;
    }
    const items = block.p.v;
    if (prev_index !== index && /** @type {number} */
    index < items.length) {
      const from_dom = (
        /** @type {Element} */
        get_first_element(block)
      );
      const from = from_dom.getBoundingClientRect();
      for (const transition2 of transitions) {
        if (transition2.r === "key") {
          transition2.c();
        }
      }
      schedule_task(() => {
        trigger_transitions(transitions, "key", from);
      });
    }
  }
  const all_registerd_events = /* @__PURE__ */ new Set();
  const root_event_handles = /* @__PURE__ */ new Set();
  function empty() {
    return document.createTextNode("");
  }
  // @__NO_SIDE_EFFECTS__
  function template(html2, is_fragment) {
    let cached_content;
    return () => {
      if (cached_content === void 0) {
        const content = create_fragment_from_html(html2);
        cached_content = is_fragment ? content : (
          /** @type {Node} */
          /* @__PURE__ */ child(content)
        );
      }
      return cached_content;
    };
  }
  // @__NO_SIDE_EFFECTS__
  function svg_template(svg, is_fragment) {
    let cached_content;
    return () => {
      if (cached_content === void 0) {
        const content = (
          /** @type {Node} */
          /* @__PURE__ */ child(create_fragment_from_html(`<svg>${svg}</svg>`))
        );
        cached_content = is_fragment ? content : (
          /** @type {Node} */
          /* @__PURE__ */ child(content)
        );
      }
      return cached_content;
    };
  }
  function svg_replace(node) {
    const first_child = (
      /** @type {Element} */
      node.firstChild
    );
    node.replaceWith(first_child);
    return first_child;
  }
  function open_template(is_fragment, use_clone_node, anchor, template_element_fn) {
    if (current_hydration_fragment !== null) {
      if (anchor !== null) {
        hydrate_block_anchor(anchor, false);
      }
      const fragment = current_hydration_fragment;
      if (fragment !== null) {
        return is_fragment ? fragment : (
          /** @type {Element} */
          fragment[0]
        );
      }
    }
    return use_clone_node ? /* @__PURE__ */ clone_node(
      /** @type {() => Element} */
      template_element_fn(),
      true
    ) : document.importNode(
      /** @type {() => Element} */
      template_element_fn(),
      true
    );
  }
  // @__NO_SIDE_EFFECTS__
  function open(anchor, use_clone_node, template_element_fn) {
    return open_template(false, use_clone_node, anchor, template_element_fn);
  }
  // @__NO_SIDE_EFFECTS__
  function open_frag(anchor, use_clone_node, template_element_fn) {
    return open_template(true, use_clone_node, anchor, template_element_fn);
  }
  const space_template = /* @__PURE__ */ template(" ", false);
  const comment_template = /* @__PURE__ */ template("<!>", true);
  // @__NO_SIDE_EFFECTS__
  function space(anchor) {
    return /* @__PURE__ */ open(anchor, true, space_template);
  }
  // @__NO_SIDE_EFFECTS__
  function comment(anchor) {
    return /* @__PURE__ */ open_frag(anchor, true, comment_template);
  }
  function close_template(dom, is_fragment, anchor) {
    const block = (
      /** @type {import('./types.js').Block} */
      current_block
    );
    const current = is_fragment ? is_array(dom) ? dom : (
      /** @type {import('./types.js').TemplateNode[]} */
      Array.from(dom.childNodes)
    ) : dom;
    if (anchor !== null) {
      if (current_hydration_fragment === null) {
        insert(current, null, anchor);
      }
    }
    block.d = current;
  }
  function close(anchor, dom) {
    close_template(dom, false, anchor);
  }
  function close_frag(anchor, dom) {
    close_template(dom, true, anchor);
  }
  function trusted(fn) {
    return function(...args) {
      const event2 = (
        /** @type {Event} */
        args[0]
      );
      if (event2.isTrusted) {
        fn.apply(this, args);
      }
    };
  }
  function self2(fn) {
    return function(...args) {
      const event2 = (
        /** @type {Event} */
        args[0]
      );
      if (event2.target === this) {
        fn.apply(this, args);
      }
    };
  }
  function stopPropagation(fn) {
    return function(...args) {
      const event2 = (
        /** @type {Event} */
        args[0]
      );
      event2.stopPropagation();
      return fn.apply(this, args);
    };
  }
  function once(fn) {
    let ran = false;
    return function(...args) {
      if (ran) {
        return;
      }
      ran = true;
      return fn.apply(this, args);
    };
  }
  function stopImmediatePropagation(fn) {
    return function(...args) {
      const event2 = (
        /** @type {Event} */
        args[0]
      );
      event2.stopImmediatePropagation();
      return fn.apply(this, args);
    };
  }
  function preventDefault(fn) {
    return function(...args) {
      const event2 = (
        /** @type {Event} */
        args[0]
      );
      event2.preventDefault();
      return fn.apply(this, args);
    };
  }
  function event(event_name, dom, handler2, capture, passive) {
    const options = {
      capture,
      passive
    };
    const target_handler = handler2;
    dom.addEventListener(event_name, target_handler, options);
    if (dom === document.body || dom === window || dom === document) {
      render_effect(() => {
        return () => {
          dom.removeEventListener(event_name, target_handler, options);
        };
      });
    }
  }
  function class_name_effect(dom, value) {
    render_effect(() => {
      const string = value();
      class_name(dom, string);
    });
  }
  function class_name(dom, value) {
    const prev_class_name = dom.__className;
    const next_class_name = to_class(value);
    const is_hydrating = current_hydration_fragment !== null;
    if (is_hydrating && dom.className === next_class_name) {
      dom.__className = next_class_name;
    } else if (prev_class_name !== next_class_name || is_hydrating && dom.className !== next_class_name) {
      if (next_class_name === "") {
        dom.removeAttribute("class");
      } else {
        set_class_name(dom, next_class_name);
      }
      dom.__className = next_class_name;
    }
  }
  function text_effect(dom, value) {
    render_effect(() => text(dom, value()));
  }
  function text(dom, value) {
    const prev_node_value = dom.__nodeValue;
    const next_node_value = stringify(value);
    if (current_hydration_fragment !== null && dom.nodeValue === next_node_value) {
      dom.__nodeValue = next_node_value;
    } else if (prev_node_value !== next_node_value) {
      dom.nodeValue = next_node_value;
      dom.__nodeValue = next_node_value;
    }
  }
  function auto_focus(dom, value) {
    if (value) {
      const body = document.body;
      dom.autofocus = true;
      render_effect(
        () => {
          if (document.activeElement === body) {
            dom.focus();
          }
        },
        current_block,
        true,
        false
      );
    }
  }
  function to_class(value) {
    return value == null ? "" : value;
  }
  function class_toggle(dom, class_name2, value) {
    if (value) {
      dom.classList.add(class_name2);
    } else {
      dom.classList.remove(class_name2);
    }
  }
  function select_option(select, value, mounting) {
    if (select.multiple) {
      return select_options(select, value);
    }
    for (const option of select.options) {
      const option_value = get_option_value(option);
      if (option_value === value) {
        option.selected = true;
        return;
      }
    }
    if (!mounting || value !== void 0) {
      select.selectedIndex = -1;
    }
  }
  function select_options(select, value) {
    for (const option of select.options) {
      option.selected = ~value.indexOf(get_option_value(option));
    }
  }
  function get_option_value(option) {
    if ("__value" in option) {
      return option.__value;
    } else {
      return option.value;
    }
  }
  function bind_online(update2) {
    const status_changed = () => {
      update2(navigator.onLine);
    };
    listen_to_events(window, ["online", "offline"], status_changed);
  }
  function time_ranges_to_array(ranges) {
    const array = [];
    for (let i = 0; i < ranges.length; i += 1) {
      array.push({ start: ranges.start(i), end: ranges.end(i) });
    }
    return array;
  }
  function bind_current_time(media, get_value, update2) {
    let raf_id;
    let updating = false;
    const callback = () => {
      cancelAnimationFrame(raf_id);
      if (!media.paused) {
        raf_id = requestAnimationFrame(callback);
      }
      updating = true;
      update2(media.currentTime);
    };
    raf_id = requestAnimationFrame(callback);
    media.addEventListener("timeupdate", callback);
    render_effect(() => {
      const value = get_value();
      if (!updating && !isNaN(
        /** @type {any} */
        value
      )) {
        media.currentTime = /** @type {number} */
        value;
      }
      updating = false;
    });
    render_effect(() => () => cancelAnimationFrame(raf_id));
  }
  function bind_buffered(media, update2) {
    const callback = () => {
      update2(time_ranges_to_array(media.buffered));
    };
    listen_to_events(media, ["loadedmetadata", "progress"], callback);
  }
  function bind_seekable(media, update2) {
    const callback = () => {
      update2(time_ranges_to_array(media.seekable));
    };
    listen_to_events(media, ["loadedmetadata"], callback);
  }
  function bind_played(media, update2) {
    const callback = () => {
      update2(time_ranges_to_array(media.played));
    };
    listen_to_events(media, ["timeupdate"], callback);
  }
  function bind_seeking(media, update2) {
    const callback = () => {
      update2(media.seeking);
    };
    listen_to_events(media, ["seeking", "seeked"], callback);
  }
  function bind_ended(media, update2) {
    const callback = () => {
      update2(media.ended);
    };
    listen_to_events(media, ["timeupdate", "ended"], callback);
  }
  function bind_ready_state(media, update2) {
    const callback = () => {
      update2(media.readyState);
    };
    listen_to_events(
      media,
      ["loadedmetadata", "loadeddata", "canplay", "canplaythrough", "playing", "waiting", "emptied"],
      callback
    );
  }
  function bind_playback_rate(media, get_value, update2) {
    let updating = false;
    const callback = () => {
      if (!updating) {
        update2(media.playbackRate);
      }
      updating = false;
    };
    let render;
    let destroyed = false;
    const effect2 = managed_effect(() => {
      destroy_signal(effect2);
      if (destroyed)
        return;
      if (get_value() == null) {
        callback();
      }
      listen_to_events(media, ["ratechange"], callback, false);
      render = render_effect(() => {
        const value = get_value();
        if (!isNaN(
          /** @type {any} */
          value
        ) && value !== media.playbackRate) {
          updating = true;
          media.playbackRate = /** @type {number} */
          value;
        }
      });
    });
    render_effect(() => () => {
      destroyed = true;
      if (render) {
        destroy_signal(render);
      }
    });
  }
  function bind_paused(media, get_value, update2) {
    let mounted = current_hydration_fragment !== null;
    let paused = get_value();
    const callback = () => {
      if (paused !== media.paused) {
        paused = media.paused;
        update2(paused = media.paused);
      }
    };
    if (paused == null) {
      callback();
    }
    if (mounted) {
      listen_to_events(media, ["play", "pause", "canplay"], callback, false);
    }
    render_effect(() => {
      paused = !!get_value();
      if (paused !== media.paused) {
        const toggle = () => {
          mounted = true;
          if (paused) {
            media.pause();
          } else {
            media.play().catch(() => {
              update2(paused = true);
            });
          }
        };
        if (mounted) {
          toggle();
        } else {
          media.addEventListener(
            "canplay",
            () => {
              listen_to_events(media, ["play", "pause", "canplay"], callback, false);
              toggle();
            },
            { once: true }
          );
        }
      }
    });
  }
  function bind_volume(media, get_value, update2) {
    let updating = false;
    const callback = () => {
      updating = true;
      update2(media.volume);
    };
    if (get_value() == null) {
      callback();
    }
    listen_to_events(media, ["volumechange"], callback, false);
    render_effect(() => {
      const value = get_value();
      if (!updating && !isNaN(
        /** @type {any} */
        value
      )) {
        media.volume = /** @type {number} */
        value;
      }
      updating = false;
    });
  }
  function bind_muted(media, get_value, update2) {
    let updating = false;
    const callback = () => {
      updating = true;
      update2(media.muted);
    };
    if (get_value() == null) {
      callback();
    }
    listen_to_events(media, ["volumechange"], callback, false);
    render_effect(() => {
      const value = get_value();
      if (!updating) {
        media.muted = !!value;
      }
      updating = false;
    });
  }
  function listen_to_events(dom, events, handler2, call_handler_immediately = true) {
    if (call_handler_immediately) {
      handler2();
    }
    for (const name of events) {
      dom.addEventListener(name, handler2);
    }
    render_effect(() => {
      return () => {
        for (const name of events) {
          dom.removeEventListener(name, handler2);
        }
      };
    });
  }
  const _ResizeObserverSingleton = class _ResizeObserverSingleton {
    /** @param {ResizeObserverOptions} options */
    constructor(options) {
      __privateAdd(this, _getObserver);
      /** */
      __privateAdd(this, _listeners, /* @__PURE__ */ new WeakMap());
      /** @type {ResizeObserver | undefined} */
      __privateAdd(this, _observer, void 0);
      /** @type {ResizeObserverOptions} */
      __privateAdd(this, _options, void 0);
      __privateSet(this, _options, options);
    }
    /**
     * @param {Element} element
     * @param {(entry: ResizeObserverEntry) => any} listener
     */
    observe(element2, listener) {
      const listeners = __privateGet(this, _listeners).get(element2) || /* @__PURE__ */ new Set();
      listeners.add(listener);
      __privateGet(this, _listeners).set(element2, listeners);
      __privateMethod(this, _getObserver, getObserver_fn).call(this).observe(element2, __privateGet(this, _options));
      return () => {
        const listeners2 = __privateGet(this, _listeners).get(element2);
        listeners2.delete(listener);
        if (listeners2.size === 0) {
          __privateGet(this, _listeners).delete(element2);
          __privateGet(this, _observer).unobserve(element2);
        }
      };
    }
  };
  _listeners = new WeakMap();
  _observer = new WeakMap();
  _options = new WeakMap();
  _getObserver = new WeakSet();
  getObserver_fn = function() {
    return __privateGet(this, _observer) ?? __privateSet(this, _observer, new ResizeObserver(
      /** @param {any} entries */
      (entries) => {
        for (const entry of entries) {
          _ResizeObserverSingleton.entries.set(entry.target, entry);
          for (const listener of __privateGet(this, _listeners).get(entry.target) || []) {
            listener(entry);
          }
        }
      }
    ));
  };
  /** @static */
  __publicField(_ResizeObserverSingleton, "entries", /* @__PURE__ */ new WeakMap());
  let ResizeObserverSingleton = _ResizeObserverSingleton;
  const resize_observer_content_box = /* @__PURE__ */ new ResizeObserverSingleton({
    box: "content-box"
  });
  const resize_observer_border_box = /* @__PURE__ */ new ResizeObserverSingleton({
    box: "border-box"
  });
  const resize_observer_device_pixel_content_box = /* @__PURE__ */ new ResizeObserverSingleton({
    box: "device-pixel-content-box"
  });
  function bind_resize_observer(dom, type, update2) {
    const observer = type === "contentRect" || type === "contentBoxSize" ? resize_observer_content_box : type === "borderBoxSize" ? resize_observer_border_box : resize_observer_device_pixel_content_box;
    const unsub = observer.observe(
      dom,
      /** @param {any} entry */
      (entry) => update2(entry[type])
    );
    render_effect(() => unsub);
  }
  function bind_element_size(dom, type, update2) {
    requestAnimationFrame(() => requestAnimationFrame(() => update2(dom[type])));
    const unsub = resize_observer_border_box.observe(dom, () => update2(dom[type]));
    render_effect(() => unsub);
  }
  function bind_window_size(type, update2) {
    const callback = () => update2(window[type]);
    listen_to_events(window, ["resize"], callback);
  }
  function selected(dom) {
    effect(() => {
      let select = dom.parentNode;
      while (select != null) {
        if (select.nodeName === "SELECT") {
          break;
        }
        select = select.parentNode;
      }
      if (select != null && dom.__value === select.__value) {
        dom.selected = true;
      }
    });
  }
  function bind_value(dom, get_value, update2) {
    dom.addEventListener("input", () => {
      let value = dom.value;
      const type = dom.type;
      if (type === "number" || type === "range") {
        value = value === "" ? null : +value;
      }
      update2(value);
    });
    render_effect(() => {
      const value = get_value();
      const coerced_value = value == null ? null : value + "";
      dom.value = coerced_value;
      dom.__value = value;
    });
  }
  function bind_select_value(dom, get_value, update2) {
    let mounting = true;
    dom.addEventListener("change", () => {
      let value;
      if (dom.multiple) {
        value = [].map.call(dom.querySelectorAll(":checked"), get_option_value);
      } else {
        const selected_option = dom.querySelector(":checked");
        value = selected_option && get_option_value(selected_option);
      }
      update2(value);
    });
    effect(() => {
      let value = get_value();
      select_option(dom, value, mounting);
      if (mounting && value === void 0) {
        let selected_option = dom.querySelector(":checked");
        if (selected_option !== null) {
          value = get_option_value(selected_option);
          update2(value);
        }
      }
      dom.__value = value;
      mounting = false;
    });
  }
  function bind_content_editable(property, dom, get_value, update2) {
    dom.addEventListener("input", () => {
      const value = dom[property];
      update2(value);
    });
    render_effect(() => {
      const value = get_value();
      if (dom[property] !== value) {
        if (value === null) {
          const non_null_value = dom[property];
          update2(non_null_value);
        } else {
          dom[property] = value + "";
        }
      }
    });
  }
  function get_binding_group_value(group, __value, checked) {
    const value = /* @__PURE__ */ new Set();
    for (let i = 0; i < group.length; i += 1) {
      if (group[i].checked) {
        value.add(group[i].__value);
      }
    }
    if (!checked) {
      value.delete(__value);
    }
    return Array.from(value);
  }
  function bind_group(group, group_index, dom, get_value, update2) {
    const is_checkbox = dom.getAttribute("type") === "checkbox";
    let binding_group = group;
    if (group_index !== null) {
      for (const index of group_index) {
        const group2 = binding_group;
        binding_group = group2[index];
        if (binding_group === void 0) {
          binding_group = group2[index] = [];
        }
      }
    }
    binding_group.push(dom);
    dom.addEventListener("change", () => {
      let value = dom.__value;
      if (is_checkbox) {
        value = get_binding_group_value(binding_group, value, dom.checked);
      }
      update2(value);
    });
    render_effect(() => {
      let value = get_value();
      if (is_checkbox) {
        value = value || [];
        dom.checked = value.includes(dom.__value);
      } else {
        dom.checked = dom.__value === value;
      }
    });
    render_effect(() => {
      return () => {
        const index = binding_group.indexOf(dom);
        if (index !== -1) {
          binding_group.splice(index, 1);
        }
      };
    });
  }
  function bind_checked(dom, get_value, update2) {
    dom.addEventListener("change", () => {
      const value = dom.checked;
      update2(value);
    });
    if (get_value() == void 0) {
      update2(false);
    }
    render_effect(() => {
      const value = get_value();
      dom.checked = Boolean(value);
    });
  }
  function bind_window_scroll(type, get_value, update2) {
    const is_scrolling_x = type === "x";
    const target_handler = () => {
      scrolling = true;
      clearTimeout(timeout);
      timeout = setTimeout(clear, 100);
      const value = window[is_scrolling_x ? "scrollX" : "scrollY"];
      update2(value);
    };
    addEventListener("scroll", target_handler, {
      passive: true
    });
    let latest_value = 0;
    let scrolling = false;
    let timeout;
    const clear = () => {
      scrolling = false;
    };
    render_effect(() => {
      latest_value = get_value() || 0;
      if (!scrolling) {
        scrolling = true;
        clearTimeout(timeout);
        if (is_scrolling_x) {
          scrollTo(latest_value, window.scrollY);
        } else {
          scrollTo(window.scrollX, latest_value);
        }
        timeout = setTimeout(clear, 100);
      }
    });
    render_effect(() => {
      return () => {
        removeEventListener("scroll", target_handler);
      };
    });
  }
  function bind_property(property, event_name, type, dom, get_value, update2) {
    const target_handler = () => {
      const value = dom[property];
      update2(value);
    };
    dom.addEventListener(event_name, target_handler);
    if (type === "set") {
      render_effect(() => {
        const value = get_value();
        dom[property] = value;
      });
    }
    if (type === "get") {
      const value = dom[property];
      update2(value);
    }
    render_effect(() => {
      if (dom === document.body || dom === window || dom === document) {
        return () => {
          dom.removeEventListener(event_name, target_handler);
        };
      }
    });
  }
  function bind_prop(props, prop2, value) {
    const desc = get_descriptor(props, prop2);
    if (desc && desc.set) {
      props[prop2] = value;
      render_effect(() => () => {
        props[prop2] = null;
      });
    }
  }
  function bind_this(element_or_component, update2, binding) {
    untrack(() => {
      update2(element_or_component);
      render_effect(() => () => {
        render_effect(() => {
          untrack(() => {
            if (!is_signal(binding) || binding.v === element_or_component) {
              update2(null);
            }
          });
        });
      });
    });
  }
  function delegate(events) {
    for (let i = 0; i < events.length; i++) {
      all_registerd_events.add(events[i]);
    }
    for (const fn of root_event_handles) {
      fn(events);
    }
  }
  function handle_event_propagation(root_element, event2) {
    var _a;
    const event_name = event2.type;
    const path = ((_a = event2.composedPath) == null ? void 0 : _a.call(event2)) || [];
    let current_target = (
      /** @type {null | Element} */
      path[0] || event2.target
    );
    if (event2.target !== current_target) {
      define_property(event2, "target", {
        configurable: true,
        value: current_target
      });
    }
    let path_idx = 0;
    const handled_at = event2.__root;
    if (handled_at) {
      const at_idx = path.indexOf(handled_at);
      if (at_idx < path.indexOf(root_element)) {
        path_idx = at_idx;
      }
    }
    current_target = /** @type {Element} */
    path[path_idx] || event2.target;
    define_property(event2, "currentTarget", {
      configurable: true,
      get() {
        return current_target || document;
      }
    });
    while (current_target !== null) {
      const parent_element = current_target.parentNode || /** @type {any} */
      current_target.host || null;
      const internal_prop_name = "__" + event_name;
      const delegated = current_target[internal_prop_name];
      if (delegated !== void 0 && !/** @type {any} */
      current_target.disabled) {
        if (is_array(delegated)) {
          const [fn, ...data] = delegated;
          fn.apply(current_target, [event2, ...data]);
        } else {
          delegated.call(current_target, event2);
        }
      }
      if (event2.cancelBubble || parent_element === root_element) {
        break;
      }
      current_target = parent_element;
    }
    event2.__root = root_element;
  }
  function slot(anchor_node, slot_fn, slot_props, fallback_fn) {
    hydrate_block_anchor(anchor_node);
    if (slot_fn === void 0) {
      if (fallback_fn !== null) {
        fallback_fn(anchor_node);
      }
    } else {
      slot_fn(anchor_node, slot_props);
    }
  }
  function if_block(anchor_node, condition_fn, consequent_fn, alternate_fn) {
    const block = create_if_block();
    hydrate_block_anchor(anchor_node);
    const previous_hydration_fragment = current_hydration_fragment;
    let consequent_dom = null;
    let alternate_dom = null;
    let has_mounted = false;
    let has_mounted_branch = false;
    const if_effect = render_effect(
      () => {
        var _a;
        const result = !!condition_fn();
        if (block.v !== result || !has_mounted) {
          block.v = result;
          if (has_mounted) {
            const consequent_transitions = block.c;
            const alternate_transitions = block.a;
            if (result) {
              if (alternate_transitions === null || alternate_transitions.size === 0) {
                execute_effect(alternate_effect);
              } else {
                trigger_transitions(alternate_transitions, "out");
              }
              if (consequent_transitions === null || consequent_transitions.size === 0) {
                execute_effect(consequent_effect);
              } else {
                trigger_transitions(consequent_transitions, "in");
              }
            } else {
              if (consequent_transitions === null || consequent_transitions.size === 0) {
                execute_effect(consequent_effect);
              } else {
                trigger_transitions(consequent_transitions, "out");
              }
              if (alternate_transitions === null || alternate_transitions.size === 0) {
                execute_effect(alternate_effect);
              } else {
                trigger_transitions(alternate_transitions, "in");
              }
            }
          } else if (current_hydration_fragment !== null) {
            const comment_text = (
              /** @type {Comment} */
              (_a = current_hydration_fragment == null ? void 0 : current_hydration_fragment[0]) == null ? void 0 : _a.data
            );
            if (!comment_text || comment_text === "ssr:if:true" && !result || comment_text === "ssr:if:false" && result) {
              remove(current_hydration_fragment);
              set_current_hydration_fragment(null);
            } else {
              current_hydration_fragment.shift();
            }
          }
          has_mounted = true;
        }
      },
      block,
      false
    );
    const consequent_effect = render_effect(
      () => {
        if (consequent_dom !== null) {
          remove(consequent_dom);
          consequent_dom = null;
        }
        if (block.v) {
          consequent_fn(anchor_node);
          if (!has_mounted_branch) {
            set_current_hydration_fragment(previous_hydration_fragment);
            has_mounted_branch = true;
          }
        }
        consequent_dom = block.d;
        block.d = null;
      },
      block,
      true
    );
    block.ce = consequent_effect;
    const alternate_effect = render_effect(
      () => {
        if (alternate_dom !== null) {
          remove(alternate_dom);
          alternate_dom = null;
        }
        if (!block.v) {
          if (alternate_fn !== null) {
            alternate_fn(anchor_node);
          }
          if (!has_mounted_branch) {
            set_current_hydration_fragment(previous_hydration_fragment);
            has_mounted_branch = true;
          }
        }
        alternate_dom = block.d;
        block.d = null;
      },
      block,
      true
    );
    block.ae = alternate_effect;
    push_destroy_fn(if_effect, () => {
      if (consequent_dom !== null) {
        remove(consequent_dom);
      }
      if (alternate_dom !== null) {
        remove(alternate_dom);
      }
      destroy_signal(consequent_effect);
      destroy_signal(alternate_effect);
    });
    block.e = if_effect;
  }
  function head(render_fn) {
    const block = create_head_block();
    const hydration_fragment = current_hydration_fragment !== null ? get_hydration_fragment(document.head.firstChild) : null;
    const previous_hydration_fragment = current_hydration_fragment;
    set_current_hydration_fragment(hydration_fragment);
    try {
      const head_effect = render_effect(
        () => {
          const current = block.d;
          if (current !== null) {
            remove(current);
            block.d = null;
          }
          let anchor = null;
          if (current_hydration_fragment === null) {
            anchor = empty();
            document.head.appendChild(anchor);
          }
          render_fn(anchor);
        },
        block,
        false
      );
      push_destroy_fn(head_effect, () => {
        const current = block.d;
        if (current !== null) {
          remove(current);
        }
      });
      block.e = head_effect;
    } finally {
      set_current_hydration_fragment(previous_hydration_fragment);
    }
  }
  function swap_block_dom(block, from, to) {
    const dom = block.d;
    if (is_array(dom)) {
      for (let i = 0; i < dom.length; i++) {
        if (dom[i] === from) {
          dom[i] = to;
          break;
        }
      }
    } else if (dom === from) {
      block.d = to;
    }
  }
  function element(anchor_node, tag_fn, render_fn, is_svg = false) {
    const block = create_dynamic_element_block();
    hydrate_block_anchor(anchor_node);
    let has_mounted = false;
    let tag;
    let element2 = null;
    const element_effect = render_effect(
      () => {
        tag = tag_fn();
        if (has_mounted) {
          execute_effect(render_effect_signal);
        }
        has_mounted = true;
      },
      block,
      false
    );
    const render_effect_signal = render_effect(
      () => {
        const next_element = tag ? current_hydration_fragment !== null ? (
          /** @type {HTMLElement | SVGElement} */
          current_hydration_fragment[0]
        ) : is_svg ? document.createElementNS("http://www.w3.org/2000/svg", tag) : document.createElement(tag) : null;
        const prev_element = element2;
        if (prev_element !== null) {
          block.d = null;
        }
        element2 = next_element;
        if (element2 !== null && render_fn !== void 0) {
          let anchor;
          if (current_hydration_fragment !== null) {
            anchor = /** @type {Comment} */
            element2.firstChild;
          } else {
            anchor = empty();
            element2.appendChild(anchor);
          }
          render_fn(element2, anchor);
        }
        const has_prev_element = prev_element !== null;
        if (has_prev_element) {
          remove(prev_element);
        }
        if (element2 !== null) {
          insert(element2, null, anchor_node);
          if (has_prev_element) {
            const parent_block = block.p;
            swap_block_dom(parent_block, prev_element, element2);
          }
        }
      },
      block,
      true
    );
    push_destroy_fn(element_effect, () => {
      if (element2 !== null) {
        remove(element2);
        block.d = null;
        element2 = null;
      }
      destroy_signal(render_effect_signal);
    });
    block.e = element_effect;
  }
  function component(anchor_node, component_fn, render_fn) {
    const block = create_dynamic_component_block();
    let current_render = null;
    hydrate_block_anchor(anchor_node);
    let component2 = null;
    block.r = /**
     * @param {import('./types.js').Transition} transition
     * @returns {void}
     */
    (transition2) => {
      const render2 = (
        /** @type {import('./types.js').Render} */
        current_render
      );
      const transitions = render2.s;
      transitions.add(transition2);
      transition2.f(() => {
        transitions.delete(transition2);
        if (transitions.size === 0) {
          if (render2.e !== null) {
            if (render2.d !== null) {
              remove(render2.d);
              render2.d = null;
            }
            destroy_signal(render2.e);
            render2.e = null;
          }
        }
      });
    };
    const create_render_effect = () => {
      const render2 = {
        d: null,
        e: null,
        s: /* @__PURE__ */ new Set(),
        p: current_render
      };
      const effect2 = render_effect(
        () => {
          const current = block.d;
          if (current !== null) {
            remove(current);
            block.d = null;
          }
          if (component2) {
            render_fn(component2);
          }
          render2.d = block.d;
          block.d = null;
        },
        block,
        true
      );
      render2.e = effect2;
      current_render = render2;
    };
    const render = () => {
      const render2 = current_render;
      if (render2 === null) {
        create_render_effect();
        return;
      }
      const transitions = render2.s;
      if (transitions.size === 0) {
        if (render2.d !== null) {
          remove(render2.d);
          render2.d = null;
        }
        if (render2.e) {
          execute_effect(render2.e);
        } else {
          create_render_effect();
        }
      } else {
        create_render_effect();
        trigger_transitions(transitions, "out");
      }
    };
    const component_effect = render_effect(
      () => {
        const next_component = component_fn();
        if (component2 !== next_component) {
          component2 = next_component;
          render();
        }
      },
      block,
      false
    );
    push_destroy_fn(component_effect, () => {
      let render2 = current_render;
      while (render2 !== null) {
        const dom = render2.d;
        if (dom !== null) {
          remove(dom);
        }
        const effect2 = render2.e;
        if (effect2 !== null) {
          destroy_signal(effect2);
        }
        render2 = render2.p;
      }
    });
    block.e = component_effect;
  }
  function await_block(anchor_node, input, pending_fn, then_fn, catch_fn) {
    const block = create_await_block();
    let current_render = null;
    hydrate_block_anchor(anchor_node);
    let latest_token;
    let resolved_value = UNINITIALIZED;
    let error = UNINITIALIZED;
    let pending = false;
    block.r = /**
     * @param {import('./types.js').Transition} transition
     * @returns {void}
     */
    (transition2) => {
      const render2 = (
        /** @type {import('./types.js').Render} */
        current_render
      );
      const transitions = render2.s;
      transitions.add(transition2);
      transition2.f(() => {
        transitions.delete(transition2);
        if (transitions.size === 0) {
          if (render2.e !== null) {
            if (render2.d !== null) {
              remove(render2.d);
              render2.d = null;
            }
            destroy_signal(render2.e);
            render2.e = null;
          }
        }
      });
    };
    const create_render_effect = () => {
      const render2 = {
        d: null,
        e: null,
        s: /* @__PURE__ */ new Set(),
        p: current_render
      };
      const effect2 = render_effect(
        () => {
          if (error === UNINITIALIZED) {
            if (resolved_value === UNINITIALIZED) {
              block.n = true;
              if (pending_fn !== null) {
                pending_fn(anchor_node);
              }
            } else if (then_fn !== null) {
              block.n = false;
              then_fn(anchor_node, resolved_value);
            }
          } else if (catch_fn !== null) {
            block.n = false;
            catch_fn(anchor_node, error);
          }
          render2.d = block.d;
          block.d = null;
        },
        block,
        true,
        true
      );
      render2.e = effect2;
      current_render = render2;
    };
    const render = () => {
      const render2 = current_render;
      if (render2 === null) {
        create_render_effect();
        return;
      }
      const transitions = render2.s;
      if (transitions.size === 0) {
        if (render2.d !== null) {
          remove(render2.d);
          render2.d = null;
        }
        if (render2.e) {
          execute_effect(render2.e);
        } else {
          create_render_effect();
        }
      } else {
        create_render_effect();
        trigger_transitions(transitions, "out");
      }
    };
    const await_effect = render_effect(
      () => {
        const token = {};
        latest_token = token;
        const promise = input();
        if (is_promise(promise)) {
          promise.then(
            /** @param {V} v */
            (v) => {
              if (latest_token === token) {
                flushSync();
                resolved_value = v;
                pending = false;
                render();
              }
            },
            /** @param {unknown} _error */
            (_error) => {
              error = _error;
              pending = false;
              render();
            }
          );
          if (resolved_value !== UNINITIALIZED || error !== UNINITIALIZED) {
            error = UNINITIALIZED;
            resolved_value = UNINITIALIZED;
          }
          if (!pending) {
            pending = true;
            render();
          }
        } else {
          error = UNINITIALIZED;
          resolved_value = promise;
          pending = false;
          render();
        }
      },
      block,
      false
    );
    push_destroy_fn(await_effect, () => {
      let render2 = current_render;
      latest_token = {};
      while (render2 !== null) {
        const dom = render2.d;
        if (dom !== null) {
          remove(dom);
        }
        const effect2 = render2.e;
        if (effect2 !== null) {
          destroy_signal(effect2);
        }
        render2 = render2.p;
      }
    });
    block.e = await_effect;
  }
  function key(anchor_node, key2, render_fn) {
    const block = create_key_block();
    let current_render = null;
    hydrate_block_anchor(anchor_node);
    let key_value = UNINITIALIZED;
    let mounted = false;
    block.r = /**
     * @param {import('./types.js').Transition} transition
     * @returns {void}
     */
    (transition2) => {
      const render2 = (
        /** @type {import('./types.js').Render} */
        current_render
      );
      const transitions = render2.s;
      transitions.add(transition2);
      transition2.f(() => {
        transitions.delete(transition2);
        if (transitions.size === 0) {
          if (render2.e !== null) {
            if (render2.d !== null) {
              remove(render2.d);
              render2.d = null;
            }
            destroy_signal(render2.e);
            render2.e = null;
          }
        }
      });
    };
    const create_render_effect = () => {
      const render2 = {
        d: null,
        e: null,
        s: /* @__PURE__ */ new Set(),
        p: current_render
      };
      const effect2 = render_effect(
        () => {
          render_fn(anchor_node);
          render2.d = block.d;
          block.d = null;
        },
        block,
        true,
        true
      );
      render2.e = effect2;
      current_render = render2;
    };
    const render = () => {
      const render2 = current_render;
      if (render2 === null) {
        create_render_effect();
        return;
      }
      const transitions = render2.s;
      if (transitions.size === 0) {
        if (render2.d !== null) {
          remove(render2.d);
          render2.d = null;
        }
        if (render2.e) {
          execute_effect(render2.e);
        } else {
          create_render_effect();
        }
      } else {
        trigger_transitions(transitions, "out");
        create_render_effect();
      }
    };
    const key_effect = render_effect(
      () => {
        const prev_key_value = key_value;
        key_value = key2();
        if (mounted && safe_not_equal(prev_key_value, key_value)) {
          render();
        }
      },
      block,
      false
    );
    render();
    mounted = true;
    push_destroy_fn(key_effect, () => {
      let render2 = current_render;
      while (render2 !== null) {
        const dom = render2.d;
        if (dom !== null) {
          remove(dom);
        }
        const effect2 = render2.e;
        if (effect2 !== null) {
          destroy_signal(effect2);
        }
        render2 = render2.p;
      }
    });
    block.e = key_effect;
  }
  function cssProps(anchor, is_html, props, component2) {
    hydrate_block_anchor(anchor);
    let tag;
    let component_anchor;
    if (current_hydration_fragment !== null) {
      tag = /** @type {HTMLElement | SVGElement} */
      current_hydration_fragment[0];
      component_anchor = /** @type {Comment} */
      tag.firstChild;
    } else {
      if (is_html) {
        tag = document.createElement("div");
        tag.style.display = "contents";
      } else {
        tag = document.createElementNS("http://www.w3.org/2000/svg", "g");
      }
      insert(tag, null, anchor);
      component_anchor = empty();
      tag.appendChild(component_anchor);
    }
    component2(component_anchor);
    let current_props = {};
    const effect2 = render_effect(() => {
      const next_props = props();
      for (const key2 in current_props) {
        if (!(key2 in next_props)) {
          tag.style.removeProperty(key2);
        }
      }
      for (const key2 in next_props) {
        tag.style.setProperty(key2, next_props[key2]);
      }
      current_props = next_props;
    });
    push_destroy_fn(effect2, () => {
      remove(tag);
    });
  }
  function stringify(value) {
    return typeof value === "string" ? value : value == null ? "" : value + "";
  }
  function html(dom, get_value, svg) {
    let html_dom;
    let value;
    const effect2 = render_effect(() => {
      if (value !== (value = get_value())) {
        if (html_dom) {
          remove(html_dom);
        }
        html_dom = reconcile_html(dom, value, svg);
      }
    });
    push_destroy_fn(effect2, () => {
      if (html_dom) {
        remove(html_dom);
      }
    });
  }
  function transition(dom, get_transition_fn, props, global = false) {
    bind_transition(dom, get_transition_fn, props, "both", global);
  }
  function animate(dom, get_transition_fn, props) {
    bind_transition(dom, get_transition_fn, props, "key", false);
  }
  function in_fn(dom, get_transition_fn, props, global = false) {
    bind_transition(dom, get_transition_fn, props, "in", global);
  }
  function out(dom, get_transition_fn, props, global = false) {
    bind_transition(dom, get_transition_fn, props, "out", global);
  }
  function action(dom, action2, value_fn) {
    let payload = void 0;
    effect(() => {
      if (value_fn) {
        const value = value_fn();
        untrack(() => {
          if (payload === void 0) {
            payload = action2(dom, value) || {};
          } else {
            const update2 = payload.update;
            if (typeof update2 === "function") {
              update2(value);
            }
          }
        });
      } else {
        untrack(() => payload = action2(dom));
      }
    });
    effect(() => {
      if (payload !== void 0) {
        const destroy = payload.destroy;
        if (typeof destroy === "function") {
          return () => {
            destroy();
          };
        }
      }
    });
  }
  function remove_input_attr_defaults(dom) {
    if (current_hydration_fragment !== null) {
      attr(dom, "value", null);
      attr(dom, "checked", null);
    }
  }
  function remove_textarea_child(dom) {
    if (current_hydration_fragment !== null && dom.firstChild !== null) {
      dom.textContent = "";
    }
  }
  function attr_effect(dom, attribute, value) {
    render_effect(() => {
      const string = value();
      attr(dom, attribute, string);
    });
  }
  function attr(dom, attribute, value) {
    value = value == null ? null : value + "";
    if (current_hydration_fragment === null || dom.getAttribute(attribute) !== value && // If we reset those, they would result in another network request, which we want to avoid.
    // We assume they are the same between client and server as checking if they are equal is expensive
    // (we can't just compare the strings as they can be different between client and server but result in the
    // same url, so we would need to create hidden anchor elements to compare them)
    attribute !== "src" && attribute !== "href" && attribute !== "srcset") {
      if (value === null) {
        dom.removeAttribute(attribute);
      } else {
        dom.setAttribute(attribute, value);
      }
    }
  }
  let src_url_equal_anchor;
  function src_url_equal(element_src, url) {
    if (element_src === url)
      return true;
    if (!src_url_equal_anchor) {
      src_url_equal_anchor = document.createElement("a");
    }
    src_url_equal_anchor.href = url;
    return element_src === src_url_equal_anchor.href;
  }
  function split_srcset(srcset) {
    return srcset.split(",").map((src) => src.trim().split(" ").filter(Boolean));
  }
  function srcset_url_equal(element2, srcset) {
    const element_urls = split_srcset(element2.srcset);
    const urls = split_srcset(srcset ?? "");
    return urls.length === element_urls.length && urls.every(
      ([url, width], i) => width === element_urls[i][1] && // We need to test both ways because Vite will create an a full URL with
      // `new URL(asset, import.meta.url).href` for the client when `base: './'`, and the
      // relative URLs inside srcset are not automatically resolved to absolute URLs by
      // browsers (in contrast to img.src). This means both SSR and DOM code could
      // contain relative or absolute URLs.
      (src_url_equal(element_urls[i][0], url) || src_url_equal(url, element_urls[i][0]))
    );
  }
  function xlink_attr_effect(dom, attribute, value) {
    render_effect(() => {
      const string = value();
      xlink_attr(dom, attribute, string);
    });
  }
  function xlink_attr(dom, attribute, value) {
    dom.setAttributeNS("http://www.w3.org/1999/xlink", attribute, value);
  }
  function set_custom_element_data_effect(node, prop2, value) {
    render_effect(() => {
      set_custom_element_data(node, prop2, value());
    });
  }
  function set_custom_element_data(node, prop2, value) {
    if (prop2 in node) {
      node[prop2] = typeof node[prop2] === "boolean" && value === "" ? true : value;
    } else {
      attr(node, prop2, value);
    }
  }
  function style(dom, key2, value, important) {
    if (value == null) {
      dom.style.removeProperty(key2);
    } else {
      dom.style.setProperty(key2, value, important ? "important" : "");
    }
  }
  const always_set_through_set_attribute = ["width", "height"];
  const setters_cache = /* @__PURE__ */ new Map();
  function get_setters(element2) {
    const setters = [];
    const descriptors = get_descriptors(element2.__proto__);
    for (const key2 in descriptors) {
      if (descriptors[key2].set && !always_set_through_set_attribute.includes(key2)) {
        setters.push(key2);
      }
    }
    return setters;
  }
  function spread_attributes(dom, prev, attrs, lowercase_attributes, css_hash) {
    const next = object_assign({}, ...attrs);
    const has_hash = css_hash.length !== 0;
    for (const key2 in prev) {
      if (!(key2 in next)) {
        next[key2] = null;
      }
    }
    if (has_hash && !next.class) {
      next.class = "";
    }
    let setters = map_get(setters_cache, dom.nodeName);
    if (!setters)
      map_set(setters_cache, dom.nodeName, setters = get_setters(dom));
    for (const key2 in next) {
      let value = next[key2];
      if (value === (prev == null ? void 0 : prev[key2]))
        continue;
      const prefix = key2[0] + key2[1];
      if (prefix === "$$")
        continue;
      if (prefix === "on") {
        const opts = {};
        let event_name = key2.slice(2);
        const delegated = DelegatedEvents.includes(event_name);
        if (event_name.endsWith("capture") && event_name !== "ongotpointercapture" && event_name !== "onlostpointercapture") {
          event_name = event_name.slice(0, -7);
          opts.capture = true;
        }
        if (!delegated && (prev == null ? void 0 : prev[key2])) {
          dom.removeEventListener(
            event_name,
            /** @type {any} */
            prev[key2],
            opts
          );
        }
        if (value != null) {
          if (!delegated) {
            dom.addEventListener(event_name, value, opts);
          } else {
            dom[`__${event_name}`] = value;
            delegate([event_name]);
          }
        }
      } else if (value == null) {
        dom.removeAttribute(key2);
      } else if (key2 === "style") {
        dom.style.cssText = value + "";
      } else if (key2 === "autofocus") {
        auto_focus(
          /** @type {HTMLElement} */
          dom,
          Boolean(value)
        );
      } else if (key2 === "__value" || key2 === "value") {
        dom.value = dom[key2] = dom.__value = value;
      } else {
        let name = key2;
        if (lowercase_attributes) {
          name = name.toLowerCase();
          name = AttributeAliases[name] || name;
        }
        if (setters.includes(name)) {
          if (current_hydration_fragment === null || //  @ts-ignore see attr method for an explanation of src/srcset
          dom[name] !== value && name !== "src" && name !== "href" && name !== "srcset") {
            dom[name] = value;
          }
        } else if (typeof value !== "function") {
          if (has_hash && name === "class") {
            if (value)
              value += " ";
            value += css_hash;
          }
          attr(dom, name, value);
        }
      }
    }
    return next;
  }
  function spread_dynamic_element_attributes(node, prev, attrs, css_hash) {
    if (node.tagName.includes("-")) {
      const next = object_assign({}, ...attrs);
      if (prev !== null) {
        for (const key2 in prev) {
          if (!(key2 in next)) {
            next[key2] = null;
          }
        }
      }
      for (const key2 in next) {
        set_custom_element_data(node, key2, next[key2]);
      }
      return next;
    } else {
      return spread_attributes(
        /** @type {Element & ElementCSSInlineStyle} */
        node,
        prev,
        attrs,
        node.namespaceURI !== "http://www.w3.org/2000/svg",
        css_hash
      );
    }
  }
  const rest_props_handler = {
    get(target, key2) {
      if (target.exclude.includes(key2))
        return;
      return target.props[key2];
    },
    getOwnPropertyDescriptor(target, key2) {
      if (target.exclude.includes(key2))
        return;
      if (key2 in target.props) {
        return {
          enumerable: true,
          configurable: true,
          value: target.props[key2]
        };
      }
    },
    has(target, key2) {
      if (target.exclude.includes(key2))
        return false;
      return key2 in target.props;
    },
    ownKeys(target) {
      const keys = [];
      for (let key2 in target.props) {
        if (!target.exclude.includes(key2))
          keys.push(key2);
      }
      return keys;
    }
  };
  function rest_props(props, rest) {
    return new Proxy({ props, exclude: rest }, rest_props_handler);
  }
  const spread_props_handler = {
    get(target, key2) {
      let i = target.props.length;
      while (i--) {
        let p = target.props[i];
        if (is_function(p))
          p = p();
        if (typeof p === "object" && p !== null && key2 in p)
          return p[key2];
      }
    },
    getOwnPropertyDescriptor() {
      return { enumerable: true, configurable: true };
    },
    has(target, key2) {
      for (let p of target.props) {
        if (is_function(p))
          p = p();
        if (key2 in p)
          return true;
      }
      return false;
    },
    ownKeys(target) {
      const keys = [];
      for (let p of target.props) {
        if (is_function(p))
          p = p();
        for (const key2 in p) {
          if (!keys.includes(key2))
            keys.push(key2);
        }
      }
      return keys;
    }
  };
  function spread_props(...props) {
    return new Proxy({ props }, spread_props_handler);
  }
  function createRoot(component2, options) {
    const props = proxy(
      /** @type {any} */
      options.props || {},
      false
    );
    let [accessors, $destroy] = mount(component2, { ...options, props });
    const result = (
      /** @type {Exports & { $destroy: () => void; $set: (props: Partial<Props>) => void; }} */
      {
        $set: (next) => {
          object_assign(props, next);
        },
        $destroy
      }
    );
    for (const key2 of object_keys(accessors || {})) {
      define_property(result, key2, {
        get() {
          return accessors[key2];
        },
        /** @param {any} value */
        set(value) {
          flushSync(() => accessors[key2] = value);
        },
        enumerable: true
      });
    }
    return result;
  }
  function mount(component2, options) {
    var _a, _b;
    init_operations();
    const registered_events = /* @__PURE__ */ new Set();
    const container = options.target;
    const block = create_root_block(options.intro || false);
    const first_child = (
      /** @type {ChildNode} */
      container.firstChild
    );
    const hydration_fragment = get_hydration_fragment(first_child);
    const previous_hydration_fragment = current_hydration_fragment;
    let accessors = void 0;
    try {
      let anchor = null;
      if (hydration_fragment === null) {
        anchor = empty();
        container.appendChild(anchor);
      }
      set_current_hydration_fragment(hydration_fragment);
      const effect2 = render_effect(
        () => {
          if (options.context) {
            push({});
            current_component_context.c = options.context;
          }
          accessors = component2(anchor, options.props || {}, options.events || {});
          if (options.context) {
            pop();
          }
        },
        block,
        true
      );
      block.e = effect2;
    } catch (error) {
      if (options.recover !== false && hydration_fragment !== null) {
        console.error(
          "ERR_SVELTE_HYDRATION_MISMATCH",
          error
        );
        remove(hydration_fragment);
        first_child.remove();
        (_b = (_a = hydration_fragment.at(-1)) == null ? void 0 : _a.nextSibling) == null ? void 0 : _b.remove();
        return mount(component2, options);
      } else {
        throw error;
      }
    } finally {
      set_current_hydration_fragment(previous_hydration_fragment);
    }
    const bound_event_listener = handle_event_propagation.bind(null, container);
    const event_handle = (events) => {
      for (let i = 0; i < events.length; i++) {
        const event_name = events[i];
        if (!registered_events.has(event_name)) {
          registered_events.add(event_name);
          container.addEventListener(
            event_name,
            bound_event_listener,
            PassiveDelegatedEvents.includes(event_name) ? {
              passive: true
            } : void 0
          );
        }
      }
    };
    event_handle(array_from(all_registerd_events));
    root_event_handles.add(event_handle);
    return [
      accessors,
      () => {
        for (const event_name of registered_events) {
          container.removeEventListener(event_name, bound_event_listener);
        }
        root_event_handles.delete(event_handle);
        const dom = block.d;
        if (dom !== null) {
          remove(dom);
        }
        if (hydration_fragment !== null) {
          remove(hydration_fragment);
        }
        destroy_signal(
          /** @type {import('./types.js').EffectSignal} */
          block.e
        );
      }
    ];
  }
  function access_props(props) {
    for (const prop2 in props) {
      props[prop2];
    }
  }
  function sanitize_slots(props) {
    const sanitized = { ...props.$$slots };
    if (props.children)
      sanitized.default = props.children;
    return sanitized;
  }
  function snippet_effect(get_snippet, node, args) {
    const block = create_snippet_block();
    render_effect(() => {
      const snippet = get_snippet();
      untrack(() => snippet(node, args));
      return () => {
        if (block.d !== null) {
          remove(block.d);
        }
      };
    }, block);
  }
  async function append_styles(target, style_sheet_id, styles) {
    await Promise.resolve();
    const append_styles_to = get_root_for_style(target);
    if (!append_styles_to.getElementById(style_sheet_id)) {
      const style2 = /* @__PURE__ */ create_element("style");
      style2.id = style_sheet_id;
      style2.textContent = styles;
      append_child(
        /** @type {Document} */
        append_styles_to.head || append_styles_to,
        style2
      );
    }
  }
  function get_root_for_style(node) {
    if (!node)
      return document;
    const root = node.getRootNode ? node.getRootNode() : node.ownerDocument;
    if (root && /** @type {ShadowRoot} */
    root.host) {
      return (
        /** @type {ShadowRoot} */
        root
      );
    }
    return (
      /** @type {Document} */
      node.ownerDocument
    );
  }
  const NEW_BLOCK = -1;
  const MOVED_BLOCK = 99999999;
  const LIS_BLOCK = -2;
  function no_op() {
  }
  function each(anchor_node, collection, flags, key_fn, render_fn, fallback_fn, reconcile_fn) {
    const is_controlled = (flags & EACH_IS_CONTROLLED) !== 0;
    const block = create_each_block(flags, anchor_node);
    let current_fallback = null;
    hydrate_block_anchor(anchor_node, is_controlled);
    let array;
    let keys = null;
    let render = null;
    block.r = /** @param {import('./types.js').Transition} transition */
    (transition2) => {
      const fallback = (
        /** @type {import('./types.js').Render} */
        current_fallback
      );
      const transitions = fallback.s;
      transitions.add(transition2);
      transition2.f(() => {
        transitions.delete(transition2);
        if (transitions.size === 0) {
          if (fallback.e !== null) {
            if (fallback.d !== null) {
              remove(fallback.d);
              fallback.d = null;
            }
            destroy_signal(fallback.e);
            fallback.e = null;
          }
        }
      });
    };
    const create_fallback_effect = () => {
      const fallback = {
        d: null,
        e: null,
        s: /* @__PURE__ */ new Set(),
        p: current_fallback
      };
      const effect2 = render_effect(
        () => {
          const dom = block.d;
          if (dom !== null) {
            remove(dom);
            block.d = null;
          }
          let anchor = block.a;
          const is_controlled2 = (block.f & EACH_IS_CONTROLLED) !== 0;
          if (is_controlled2) {
            anchor = empty();
            block.a.appendChild(anchor);
          }
          fallback_fn(anchor);
          fallback.d = block.d;
          block.d = null;
        },
        block,
        true
      );
      fallback.e = effect2;
      current_fallback = fallback;
    };
    const each2 = render_effect(
      () => {
        const maybe_array = collection();
        array = is_array(maybe_array) ? maybe_array : maybe_array == null ? [] : Array.from(maybe_array);
        if (key_fn !== null) {
          keys = array.map(key_fn);
        } else if ((flags & EACH_KEYED) === 0) {
          array.map(no_op);
        }
        const length = array.length;
        if (fallback_fn !== null) {
          if (length === 0) {
            if (block.v.length !== 0 || render === null) {
              create_fallback_effect();
            }
          } else if (block.v.length === 0 && current_fallback !== null) {
            const fallback = current_fallback;
            const transitions = fallback.s;
            if (transitions.size === 0) {
              if (fallback.d !== null) {
                remove(fallback.d);
                fallback.d = null;
              }
            } else {
              trigger_transitions(transitions, "out");
            }
          }
        }
        if (render !== null) {
          execute_effect(render);
        }
      },
      block,
      false
    );
    render = render_effect(
      /** @param {import('./types.js').EachBlock} block */
      (block2) => {
        const flags2 = block2.f;
        const is_controlled2 = (flags2 & EACH_IS_CONTROLLED) !== 0;
        const anchor_node2 = block2.a;
        reconcile_fn(array, block2, anchor_node2, is_controlled2, render_fn, flags2, true, keys);
      },
      block,
      true
    );
    push_destroy_fn(each2, () => {
      const flags2 = block.f;
      const anchor_node2 = block.a;
      const is_controlled2 = (flags2 & EACH_IS_CONTROLLED) !== 0;
      let fallback = current_fallback;
      while (fallback !== null) {
        const dom = fallback.d;
        if (dom !== null) {
          remove(dom);
        }
        const effect2 = fallback.e;
        if (effect2 !== null) {
          destroy_signal(effect2);
        }
        fallback = fallback.p;
      }
      reconcile_fn([], block, anchor_node2, is_controlled2, render_fn, flags2, false, keys);
      destroy_signal(
        /** @type {import('./types.js').EffectSignal} */
        render
      );
    });
    block.e = each2;
  }
  function each_keyed(anchor_node, collection, flags, key_fn, render_fn, fallback_fn) {
    each(anchor_node, collection, flags, key_fn, render_fn, fallback_fn, reconcile_tracked_array);
  }
  function each_indexed(anchor_node, collection, flags, render_fn, fallback_fn) {
    each(anchor_node, collection, flags, null, render_fn, fallback_fn, reconcile_indexed_array);
  }
  function reconcile_indexed_array(array, each_block, dom, is_controlled, render_fn, flags, apply_transitions) {
    var is_proxied_array = STATE_SYMBOL in array && /** @type {any} */
    array[STATE_SYMBOL].i;
    var a_blocks = each_block.v;
    var active_transitions = each_block.s;
    if (is_proxied_array) {
      flags &= ~EACH_ITEM_REACTIVE;
    }
    var a = a_blocks.length;
    var b = array.length;
    var length = Math.max(a, b);
    var index = 0;
    var b_blocks;
    var block;
    if (active_transitions.length !== 0) {
      destroy_active_transition_blocks(active_transitions);
    }
    if (b === 0) {
      b_blocks = [];
      if (is_controlled && a !== 0) {
        clear_text_content(dom);
      }
      while (index < length) {
        block = a_blocks[index++];
        destroy_each_item_block(block, active_transitions, apply_transitions, is_controlled);
      }
    } else {
      var item;
      b_blocks = Array(b);
      if (current_hydration_fragment !== null) {
        var hydrating_node = current_hydration_fragment[0];
        for (; index < length; index++) {
          item = is_proxied_array ? lazy_property(array, index) : array[index];
          var fragment = (
            /** @type {Array<Text | Comment | Element>} */
            get_hydration_fragment(hydrating_node)
          );
          set_current_hydration_fragment(fragment);
          hydrating_node = /** @type {Node} */
          /** @type {Node} */
          /** @type {Node} */
          fragment.at(-1).nextSibling.nextSibling;
          block = each_item_block(item, null, index, render_fn, flags);
          b_blocks[index] = block;
        }
      } else {
        for (; index < length; index++) {
          if (index >= a) {
            item = is_proxied_array ? lazy_property(array, index) : array[index];
            block = each_item_block(item, null, index, render_fn, flags);
            b_blocks[index] = block;
            insert_each_item_block(block, dom, is_controlled, null);
          } else if (index >= b) {
            block = a_blocks[index];
            destroy_each_item_block(block, active_transitions, apply_transitions);
          } else {
            item = array[index];
            block = a_blocks[index];
            b_blocks[index] = block;
            update_each_item_block(block, item, index, flags);
          }
        }
      }
    }
    each_block.v = b_blocks;
  }
  function reconcile_tracked_array(array, each_block, dom, is_controlled, render_fn, flags, apply_transitions, keys) {
    var a_blocks = each_block.v;
    const is_computed_key = keys !== null;
    var is_proxied_array = STATE_SYMBOL in array && /** @type {any} */
    array[STATE_SYMBOL].i;
    var active_transitions = each_block.s;
    if (is_proxied_array) {
      flags &= ~EACH_ITEM_REACTIVE;
    }
    var a = a_blocks.length;
    var b = array.length;
    var b_blocks;
    var block;
    if (active_transitions.length !== 0) {
      destroy_active_transition_blocks(active_transitions);
    }
    if (b === 0) {
      b_blocks = [];
      if (is_controlled && a !== 0) {
        clear_text_content(dom);
      }
      while (a > 0) {
        block = a_blocks[--a];
        destroy_each_item_block(block, active_transitions, apply_transitions, is_controlled);
      }
    } else {
      var a_end = a - 1;
      var b_end = b - 1;
      var key2;
      var item;
      var idx;
      b_blocks = Array(b);
      if (current_hydration_fragment !== null) {
        var fragment;
        var hydrating_node = current_hydration_fragment[0];
        while (b > 0) {
          idx = b_end - --b;
          item = array[idx];
          key2 = is_computed_key ? keys[idx] : item;
          fragment = /** @type {Array<Text | Comment | Element>} */
          get_hydration_fragment(hydrating_node);
          set_current_hydration_fragment(fragment);
          hydrating_node = /** @type {Node} */
          /** @type {Node} */
          (fragment.at(-1) || hydrating_node).nextSibling.nextSibling;
          block = each_item_block(item, key2, idx, render_fn, flags);
          b_blocks[idx] = block;
        }
      } else if (a === 0) {
        while (b > 0) {
          idx = b_end - --b;
          item = array[idx];
          key2 = is_computed_key ? keys[idx] : item;
          block = each_item_block(item, key2, idx, render_fn, flags);
          b_blocks[idx] = block;
          insert_each_item_block(block, dom, is_controlled, null);
        }
      } else {
        var should_update_block = (flags & (EACH_ITEM_REACTIVE | EACH_INDEX_REACTIVE)) !== 0;
        var start = 0;
        var sibling2 = null;
        item = array[b_end];
        key2 = is_computed_key ? keys[b_end] : item;
        outer:
          while (true) {
            while (a_blocks[a_end].k === key2) {
              block = a_blocks[a_end--];
              item = array[b_end];
              if (should_update_block) {
                update_each_item_block(block, item, b_end, flags);
              }
              sibling2 = get_first_child(block);
              b_blocks[b_end] = block;
              if (start > --b_end || start > a_end) {
                break outer;
              }
              key2 = is_computed_key ? keys[b_end] : item;
            }
            item = array[start];
            key2 = is_computed_key ? keys[start] : item;
            while (start <= a_end && start <= b_end && a_blocks[start].k === key2) {
              item = array[start];
              block = a_blocks[start];
              if (should_update_block) {
                update_each_item_block(block, item, start, flags);
              }
              b_blocks[start] = block;
              ++start;
              key2 = is_computed_key ? keys[start] : array[start];
            }
            break;
          }
        if (start > a_end) {
          while (b_end >= start) {
            item = array[b_end];
            key2 = is_computed_key ? keys[b_end] : item;
            block = each_item_block(item, key2, b_end, render_fn, flags);
            b_blocks[b_end--] = block;
            sibling2 = insert_each_item_block(block, dom, is_controlled, sibling2);
          }
        } else if (start > b_end) {
          b = start;
          do {
            if ((block = a_blocks[b++]) !== null) {
              destroy_each_item_block(block, active_transitions, apply_transitions);
            }
          } while (b <= a_end);
        } else {
          var pos = 0;
          var b_length = b_end - start + 1;
          var sources = new Int32Array(b_length);
          var item_index = /* @__PURE__ */ new Map();
          for (b = 0; b < b_length; ++b) {
            a = b + start;
            sources[b] = NEW_BLOCK;
            item = array[a];
            key2 = is_computed_key ? keys[a] : item;
            map_set(item_index, key2, a);
          }
          for (b = start; b <= a_end; ++b) {
            a = map_get(
              item_index,
              /** @type {V} */
              a_blocks[b].k
            );
            block = a_blocks[b];
            if (a !== void 0) {
              pos = pos < a ? a : MOVED_BLOCK;
              sources[a - start] = b;
              b_blocks[a] = block;
            } else if (block !== null) {
              destroy_each_item_block(block, active_transitions, apply_transitions);
            }
          }
          if (pos === MOVED_BLOCK) {
            mark_lis(sources);
          }
          var is_animated = (flags & EACH_IS_ANIMATED) !== 0;
          var should_create;
          if (is_animated) {
            var i = b_length;
            while (i-- > 0) {
              b_end = i + start;
              a = sources[i];
              if (pos === MOVED_BLOCK) {
                block = b_blocks[b_end];
                item = array[b_end];
                update_each_item_block(block, item, b_end, flags);
              }
            }
          }
          var last_block;
          var last_sibling;
          while (b_length-- > 0) {
            b_end = b_length + start;
            a = sources[b_length];
            should_create = a === -1;
            item = array[b_end];
            if (should_create) {
              key2 = is_computed_key ? keys[b_end] : item;
              block = each_item_block(item, key2, b_end, render_fn, flags);
            } else {
              block = b_blocks[b_end];
              if (!is_animated && should_update_block) {
                update_each_item_block(block, item, b_end, flags);
              }
            }
            if (should_create || pos === MOVED_BLOCK && a !== LIS_BLOCK) {
              last_sibling = last_block === void 0 ? sibling2 : get_first_child(last_block);
              sibling2 = insert_each_item_block(block, dom, is_controlled, last_sibling);
            }
            b_blocks[b_end] = block;
            last_block = block;
          }
        }
      }
    }
    each_block.v = b_blocks;
  }
  function mark_lis(a) {
    var length = a.length;
    var parent = new Int32Array(length);
    var index = new Int32Array(length);
    var index_length = 0;
    var i = 0;
    var j;
    var k;
    var lo;
    var hi;
    for (; a[i] === NEW_BLOCK; ++i) {
    }
    index[0] = i++;
    for (; i < length; ++i) {
      k = a[i];
      if (k !== NEW_BLOCK) {
        j = index[index_length];
        if (a[j] < k) {
          parent[i] = j;
          index[++index_length] = i;
        } else {
          lo = 0;
          hi = index_length;
          while (lo < hi) {
            j = lo + hi >> 1;
            if (a[index[j]] < k) {
              lo = j + 1;
            } else {
              hi = j;
            }
          }
          if (k < a[index[lo]]) {
            if (lo > 0) {
              parent[i] = index[lo - 1];
            }
            index[lo] = i;
          }
        }
      }
    }
    j = index[index_length];
    while (index_length-- >= 0) {
      a[j] = LIS_BLOCK;
      j = parent[j];
    }
  }
  function insert_each_item_block(block, dom, is_controlled, sibling2) {
    var current = (
      /** @type {import('./types.js').TemplateNode} */
      block.d
    );
    if (sibling2 === null) {
      if (is_controlled) {
        return insert(
          current,
          /** @type {Element} */
          dom,
          null
        );
      } else {
        return insert(
          current,
          /** @type {Element} */
          dom.parentNode,
          dom
        );
      }
    }
    return insert(current, null, sibling2);
  }
  function get_first_child(block) {
    var current = block.d;
    if (is_array(current)) {
      return (
        /** @type {Text | Element | Comment} */
        current[0]
      );
    }
    return (
      /** @type {Text | Element | Comment} */
      current
    );
  }
  function destroy_active_transition_blocks(active_transitions) {
    var length = active_transitions.length;
    if (length > 0) {
      var i = 0;
      var block;
      var transition2;
      for (; i < length; i++) {
        block = active_transitions[i];
        transition2 = block.r;
        if (transition2 !== null) {
          block.r = null;
          destroy_each_item_block(block, null, false);
        }
      }
      active_transitions.length = 0;
    }
  }
  function get_first_element(block) {
    const current = block.d;
    if (is_array(current)) {
      for (let i = 0; i < current.length; i++) {
        const node = current[i];
        if (node.nodeType !== 8) {
          return node;
        }
      }
    }
    return (
      /** @type {Text | Element | Comment} */
      current
    );
  }
  function update_each_item_block(block, item, index, type) {
    if ((type & EACH_ITEM_REACTIVE) !== 0) {
      set_signal_value(block.v, item);
    } else if (is_lazy_property(block.v)) {
      block.v.o[block.v.p] = item;
    }
    const transitions = block.s;
    const index_is_reactive = (type & EACH_INDEX_REACTIVE) !== 0;
    const each_animation = block.a;
    if (transitions !== null && (type & EACH_KEYED) !== 0 && each_animation !== null) {
      each_animation(block, transitions, index, index_is_reactive);
    }
    if (index_is_reactive) {
      set_signal_value(
        /** @type {import('./types.js').Signal<number>} */
        block.i,
        index
      );
    } else {
      block.i = index;
    }
  }
  function destroy_each_item_block(block, transition_block, apply_transitions, controlled = false) {
    const transitions = block.s;
    if (apply_transitions && transitions !== null) {
      trigger_transitions(transitions, "out");
      if (transition_block !== null) {
        transition_block.push(block);
      }
    } else {
      const dom = block.d;
      if (!controlled && dom !== null) {
        remove(dom);
      }
      destroy_signal(
        /** @type {import('./types.js').EffectSignal} */
        block.e
      );
    }
  }
  function each_item_block(item, key2, index, render_fn, flags) {
    const each_item_not_reactive = (flags & EACH_ITEM_REACTIVE) === 0;
    const item_value = each_item_not_reactive ? item : (flags & EACH_IS_IMMUTABLE) === 0 ? /* @__PURE__ */ mutable_source(item) : /* @__PURE__ */ source(item);
    const index_value = (flags & EACH_INDEX_REACTIVE) === 0 ? index : /* @__PURE__ */ source(index);
    const block = create_each_item_block(item_value, index_value, key2);
    const effect2 = render_effect(
      /** @param {import('./types.js').EachItemBlock} block */
      (block2) => {
        render_fn(null, block2.v, block2.i);
      },
      block,
      true
    );
    block.e = effect2;
    return block;
  }
  const void_element_names = /^(?:area|base|br|col|command|embed|hr|img|input|keygen|link|meta|param|source|track|wbr)$/;
  function is_void(tag) {
    return void_element_names.test(tag) || tag.toLowerCase() === "!doctype";
  }
  function validate_store(store, name) {
    if (store != null && typeof store.subscribe !== "function") {
      throw new Error(`'${name}' is not a store with a 'subscribe' method`);
    }
  }
  function validate_dynamic_component(component_fn) {
    const error_message = "this={...} of <svelte:component> should specify a Svelte component.";
    try {
      const instance = component_fn();
      if (instance !== void 0 && typeof instance !== "object") {
        throw new Error(error_message);
      }
      return instance;
    } catch (err) {
      const { message } = (
        /** @type {Error} */
        err
      );
      if (typeof message === "string" && message.indexOf("is not a function") !== -1) {
        throw new Error(error_message);
      } else {
        throw err;
      }
    }
  }
  function validate_void_dynamic_element(tag_fn) {
    const tag = tag_fn();
    if (tag && is_void(tag)) {
      console.warn(`<svelte:element this="${tag}"> is self-closing and cannot have content.`);
    }
  }
  function validate_dynamic_element_tag(tag_fn) {
    const tag = tag_fn();
    const is_string = typeof tag === "string";
    if (tag && !is_string) {
      throw new Error('<svelte:element> expects "this" attribute to be a string.');
    }
  }
  function validate_each_keys(collection, key_fn) {
    const keys = /* @__PURE__ */ new Map();
    const maybe_array = untrack(() => collection());
    const array = is_array(maybe_array) ? maybe_array : maybe_array == null ? [] : Array.from(maybe_array);
    const length = array.length;
    for (let i = 0; i < length; i++) {
      const key2 = key_fn(array[i], i);
      if (keys.has(key2)) {
        throw new Error(
          `Cannot have duplicate keys in a keyed each: Keys at index ${keys.get(
            key2
          )} and ${i} with value '${array[i]}' are duplicates`
        );
      }
      keys.set(key2, i);
    }
  }
  function loop_guard(timeout) {
    const start = Date.now();
    return () => {
      if (Date.now() - start > timeout) {
        throw new Error("Infinite loop detected");
      }
    };
  }
  const snippet_symbol = Symbol.for("svelte.snippet");
  function add_snippet_symbol(fn) {
    fn[snippet_symbol] = true;
    return fn;
  }
  function validate_snippet(snippet_fn) {
    if (snippet_fn[snippet_symbol] !== true) {
      throw new Error(
        "The argument to `{@render ...}` must be a snippet function, not a component or some other kind of function. If you want to dynamically render one snippet or another, use `$derived` and pass its result to `{@render ...}`."
      );
    }
    return snippet_fn;
  }
  function validate_component(component_fn) {
    if ((component_fn == null ? void 0 : component_fn[snippet_symbol]) === true) {
      throw new Error("A snippet must be rendered with `{@render ...}`");
    }
    return component_fn;
  }
  function createClassComponent(options) {
    return new Svelte4Component(options);
  }
  class Svelte4Component {
    /**
     * @param {import('../main/public.js').ComponentConstructorOptions & {
     *  component: any;
     * 	immutable?: boolean;
     * 	recover?: false;
     * }} options
     */
    constructor(options) {
      /** @type {any} */
      __privateAdd(this, _events, {});
      /** @type {ReturnType<typeof $.createRoot>} */
      __privateAdd(this, _instance, void 0);
      __privateSet(this, _instance, createRoot(options.component, {
        target: options.target,
        props: { ...options.props, $$events: __privateGet(this, _events) },
        context: options.context,
        intro: options.intro,
        recover: options.recover
      }));
      for (const key2 of Object.keys(__privateGet(this, _instance))) {
        if (key2 === "$set" || key2 === "$destroy")
          continue;
        define_property(this, key2, {
          get() {
            return __privateGet(this, _instance)[key2];
          },
          /** @param {any} value */
          set(value) {
            __privateGet(this, _instance)[key2] = value;
          },
          enumerable: true
        });
      }
    }
    /** @param {Record<string, any>} props */
    $set(props) {
      __privateGet(this, _instance).$set(props);
    }
    /**
     * @param {string} event
     * @param {(...args: any[]) => any} callback
     * @returns {any}
     */
    $on(event2, callback) {
      __privateGet(this, _events)[event2] = __privateGet(this, _events)[event2] || [];
      const cb = (...args) => callback.call(this, ...args);
      __privateGet(this, _events)[event2].push(cb);
      return () => {
        __privateGet(this, _events)[event2] = __privateGet(this, _events)[event2].filter(
          /** @param {any} fn */
          (fn) => fn !== cb
        );
      };
    }
    $destroy() {
      __privateGet(this, _instance).$destroy();
    }
  }
  _events = new WeakMap();
  _instance = new WeakMap();
  let SvelteElement;
  if (typeof HTMLElement === "function") {
    SvelteElement = class extends HTMLElement {
      /**
       * @param {*} $$componentCtor
       * @param {*} $$slots
       * @param {*} use_shadow_dom
       */
      constructor($$componentCtor, $$slots, use_shadow_dom) {
        super();
        /** The Svelte component constructor */
        __publicField(this, "$$ctor");
        /** Slots */
        __publicField(this, "$$s");
        /** @type {any} The Svelte component instance */
        __publicField(this, "$$c");
        /** Whether or not the custom element is connected */
        __publicField(this, "$$cn", false);
        /** @type {Record<string, any>} Component props data */
        __publicField(this, "$$d", {});
        /** `true` if currently in the process of reflecting component props back to attributes */
        __publicField(this, "$$r", false);
        /** @type {Record<string, CustomElementPropDefinition>} Props definition (name, reflected, type etc) */
        __publicField(this, "$$p_d", {});
        /** @type {Record<string, EventListenerOrEventListenerObject[]>} Event listeners */
        __publicField(this, "$$l", {});
        /** @type {Map<EventListenerOrEventListenerObject, Function>} Event listener unsubscribe functions */
        __publicField(this, "$$l_u", /* @__PURE__ */ new Map());
        /** @type {any} The managed render effect for reflecting attributes */
        __publicField(this, "$$me");
        this.$$ctor = $$componentCtor;
        this.$$s = $$slots;
        if (use_shadow_dom) {
          this.attachShadow({ mode: "open" });
        }
      }
      /**
       * @param {string} type
       * @param {EventListenerOrEventListenerObject} listener
       * @param {boolean | AddEventListenerOptions} [options]
       */
      addEventListener(type, listener, options) {
        this.$$l[type] = this.$$l[type] || [];
        this.$$l[type].push(listener);
        if (this.$$c) {
          const unsub = this.$$c.$on(type, listener);
          this.$$l_u.set(listener, unsub);
        }
        super.addEventListener(type, listener, options);
      }
      /**
       * @param {string} type
       * @param {EventListenerOrEventListenerObject} listener
       * @param {boolean | AddEventListenerOptions} [options]
       */
      removeEventListener(type, listener, options) {
        super.removeEventListener(type, listener, options);
        if (this.$$c) {
          const unsub = this.$$l_u.get(listener);
          if (unsub) {
            unsub();
            this.$$l_u.delete(listener);
          }
        }
      }
      async connectedCallback() {
        this.$$cn = true;
        if (!this.$$c) {
          let create_slot = function(name) {
            return (anchor) => {
              const node = /* @__PURE__ */ open(anchor, true, () => {
                const slot2 = document.createElement("slot");
                if (name !== "default") {
                  slot2.name = name;
                }
                return slot2;
              });
              close(
                anchor,
                /** @type {Element} */
                node
              );
            };
          };
          await Promise.resolve();
          if (!this.$$cn) {
            return;
          }
          const $$slots = {};
          const existing_slots = get_custom_elements_slots(this);
          for (const name of this.$$s) {
            if (name in existing_slots) {
              if (name === "default") {
                this.$$d.children = create_slot(name);
              } else {
                $$slots[name] = create_slot(name);
              }
            }
          }
          for (const attribute of this.attributes) {
            const name = this.$$g_p(attribute.name);
            if (!(name in this.$$d)) {
              this.$$d[name] = get_custom_element_value(name, attribute.value, this.$$p_d, "toProp");
            }
          }
          for (const key2 in this.$$p_d) {
            if (!(key2 in this.$$d) && this[key2] !== void 0) {
              this.$$d[key2] = this[key2];
              delete this[key2];
            }
          }
          this.$$c = createClassComponent({
            component: this.$$ctor,
            target: this.shadowRoot || this,
            props: {
              ...this.$$d,
              $$slots
            }
          });
          this.$$me = render_effect(() => {
            var _a;
            this.$$r = true;
            for (const key2 of Object.keys(this.$$c)) {
              if (!((_a = this.$$p_d[key2]) == null ? void 0 : _a.reflect))
                continue;
              this.$$d[key2] = this.$$c[key2];
              const attribute_value = get_custom_element_value(
                key2,
                this.$$d[key2],
                this.$$p_d,
                "toAttribute"
              );
              if (attribute_value == null) {
                this.removeAttribute(this.$$p_d[key2].attribute || key2);
              } else {
                this.setAttribute(this.$$p_d[key2].attribute || key2, attribute_value);
              }
            }
            this.$$r = false;
          });
          for (const type in this.$$l) {
            for (const listener of this.$$l[type]) {
              const unsub = this.$$c.$on(type, listener);
              this.$$l_u.set(listener, unsub);
            }
          }
          this.$$l = {};
        }
      }
      // We don't need this when working within Svelte code, but for compatibility of people using this outside of Svelte
      // and setting attributes through setAttribute etc, this is helpful
      /**
       * @param {string} attr
       * @param {string} _oldValue
       * @param {string} newValue
       */
      attributeChangedCallback(attr2, _oldValue, newValue) {
        var _a;
        if (this.$$r)
          return;
        attr2 = this.$$g_p(attr2);
        this.$$d[attr2] = get_custom_element_value(attr2, newValue, this.$$p_d, "toProp");
        (_a = this.$$c) == null ? void 0 : _a.$set({ [attr2]: this.$$d[attr2] });
      }
      disconnectedCallback() {
        this.$$cn = false;
        Promise.resolve().then(() => {
          if (!this.$$cn) {
            this.$$c.$destroy();
            destroy_signal(this.$$me);
            this.$$c = void 0;
          }
        });
      }
      /**
       * @param {string} attribute_name
       */
      $$g_p(attribute_name) {
        return Object.keys(this.$$p_d).find(
          (key2) => this.$$p_d[key2].attribute === attribute_name || !this.$$p_d[key2].attribute && key2.toLowerCase() === attribute_name
        ) || attribute_name;
      }
    };
  }
  function get_custom_element_value(prop2, value, props_definition, transform) {
    var _a;
    const type = (_a = props_definition[prop2]) == null ? void 0 : _a.type;
    value = type === "Boolean" && typeof value !== "boolean" ? value != null : value;
    if (!transform || !props_definition[prop2]) {
      return value;
    } else if (transform === "toAttribute") {
      switch (type) {
        case "Object":
        case "Array":
          return value == null ? null : JSON.stringify(value);
        case "Boolean":
          return value ? "" : null;
        case "Number":
          return value == null ? null : value;
        default:
          return value;
      }
    } else {
      switch (type) {
        case "Object":
        case "Array":
          return value && JSON.parse(value);
        case "Boolean":
          return value;
        case "Number":
          return value != null ? +value : value;
        default:
          return value;
      }
    }
  }
  function get_custom_elements_slots(element2) {
    const result = {};
    element2.childNodes.forEach((node) => {
      result[
        /** @type {Element} node */
        node.slot || "default"
      ] = true;
    });
    return result;
  }
  function create_custom_element(Component, props_definition, slots, accessors, use_shadow_dom, extend) {
    let Class = class extends SvelteElement {
      constructor() {
        super(Component, slots, use_shadow_dom);
        this.$$p_d = props_definition;
      }
      static get observedAttributes() {
        return Object.keys(props_definition).map(
          (key2) => (props_definition[key2].attribute || key2).toLowerCase()
        );
      }
    };
    Object.keys(props_definition).forEach((prop2) => {
      define_property(Class.prototype, prop2, {
        get() {
          return this.$$c && prop2 in this.$$c ? this.$$c[prop2] : this.$$d[prop2];
        },
        set(value) {
          var _a;
          value = get_custom_element_value(prop2, value, props_definition);
          this.$$d[prop2] = value;
          (_a = this.$$c) == null ? void 0 : _a.$set({ [prop2]: value });
        }
      });
    });
    accessors.forEach((accessor) => {
      define_property(Class.prototype, accessor, {
        get() {
          var _a;
          return (_a = this.$$c) == null ? void 0 : _a[accessor];
        }
      });
    });
    if (extend) {
      Class = extend(Class);
    }
    Component.element = /** @type {any} */
    Class;
    return Class;
  }
  const $ = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
    __proto__: null,
    access_props,
    action,
    add_snippet_symbol,
    animate,
    append_styles,
    attr,
    attr_effect,
    auto_focus,
    await: await_block,
    bind_buffered,
    bind_checked,
    bind_content_editable,
    bind_current_time,
    bind_element_size,
    bind_ended,
    bind_group,
    bind_muted,
    bind_online,
    bind_paused,
    bind_playback_rate,
    bind_played,
    bind_prop,
    bind_property,
    bind_ready_state,
    bind_resize_observer,
    bind_seekable,
    bind_seeking,
    bind_select_value,
    bind_this,
    bind_value,
    bind_volume,
    bind_window_scroll,
    bind_window_size,
    bubble_event,
    child,
    child_frag,
    class_name,
    class_name_effect,
    class_toggle,
    close,
    close_frag,
    comment,
    component,
    createRoot,
    create_custom_element,
    cssProps,
    delegate,
    derived,
    destroy_each_item_block,
    get document() {
      return $document;
    },
    each_indexed,
    each_keyed,
    effect_active,
    element,
    empty,
    event,
    exclude_from_object,
    flushSync,
    get,
    get_first_element,
    head,
    html,
    if: if_block,
    in: in_fn,
    inspect,
    invalidate_effect,
    invalidate_inner_signals,
    key,
    loop_guard,
    mount,
    mutable_source,
    mutate,
    mutate_store,
    onDestroy,
    once,
    open,
    open_frag,
    out,
    pop,
    pre_effect,
    preventDefault,
    prop,
    proxy,
    push,
    raf,
    reactive_import,
    readonly,
    remove_input_attr_defaults,
    remove_textarea_child,
    render_effect,
    rest_props,
    safe_equal,
    sanitize_slots,
    select_option,
    selected,
    self: self2,
    set,
    set_custom_element_data,
    set_custom_element_data_effect,
    set_sync,
    sibling,
    slot,
    snippet_effect,
    source,
    space,
    spread_attributes,
    spread_dynamic_element_attributes,
    spread_props,
    srcset_url_equal,
    stopImmediatePropagation,
    stopPropagation,
    store_get,
    store_set,
    stringify,
    style,
    svg_replace,
    svg_template,
    template,
    text,
    text_effect,
    tick,
    to_class,
    transition,
    trusted,
    unstate,
    unsubscribe_on_destroy,
    untrack,
    unwrap,
    update,
    update_pre,
    update_pre_prop,
    update_pre_store,
    update_prop,
    update_store,
    user_effect,
    user_root_effect,
    validate_component,
    validate_dynamic_component,
    validate_dynamic_element_tag,
    validate_each_keys,
    validate_snippet,
    validate_store,
    validate_void_dynamic_element,
    value_or_fallback,
    get window() {
      return $window;
    },
    xlink_attr,
    xlink_attr_effect
  }, Symbol.toStringTag, { value: "Module" }));
  return $;
});
