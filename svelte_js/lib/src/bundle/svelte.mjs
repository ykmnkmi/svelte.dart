const noop = () => {
};
function run_all(arr) {
  for (var i = 0; i < arr.length; i++) {
    arr[i]();
  }
}
function run(fn) {
  return fn();
}
var is_array = Array.isArray;
var array_from = Array.from;
var define_property = Object.defineProperty;
var get_descriptor = Object.getOwnPropertyDescriptor;
var get_descriptors = Object.getOwnPropertyDescriptors;
function is_function(thing) {
  return typeof thing === "function";
}
function default_equals(a, b) {
  return a === b;
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
const ROOT_BLOCK = 0;
const IF_BLOCK = 1;
const EACH_BLOCK = 2;
const EACH_ITEM_BLOCK = 3;
const UNINITIALIZED = Symbol();
const STATE_SYMBOL = Symbol("$state");
function create_computation_signal(flags, value, block) {
  const signal = {
    b: block,
    c: null,
    d: null,
    e: null,
    f: flags,
    l: 0,
    i: null,
    r: null,
    v: value,
    w: 0,
    x: null,
    y: null
  };
  return signal;
}
function push_reference(target_signal, ref_signal) {
  const references = target_signal.r;
  if (references === null) {
    target_signal.r = [ref_signal];
  } else {
    references.push(ref_signal);
  }
}
function internal_create_effect(type, fn, sync, block, schedule) {
  const signal = create_computation_signal(type | DIRTY, null, block);
  signal.i = fn;
  signal.x = current_component_context;
  if (current_effect !== null) {
    signal.l = current_effect.l + 1;
    if ((type & MANAGED) === 0) {
      push_reference(current_effect, signal);
    }
  }
  if (schedule) {
    schedule_effect(signal, sync);
  }
  return signal;
}
function user_effect(fn) {
  if (current_effect === null) {
    throw new Error(
      "ERR_SVELTE_ORPHAN_EFFECT"
    );
  }
  const apply_component_effect_heuristics = current_effect.f & RENDER_EFFECT && current_component_context !== null && !current_component_context.m;
  const effect = internal_create_effect(
    EFFECT,
    fn,
    false,
    current_block,
    !apply_component_effect_heuristics
  );
  if (apply_component_effect_heuristics) {
    const context = (
      /** @type {import('../types.js').ComponentContext} */
      current_component_context
    );
    (context.e ?? (context.e = [])).push(effect);
  }
  return effect;
}
function managed_effect(fn) {
  return internal_create_effect(EFFECT | MANAGED, fn, false, current_block, true);
}
function managed_pre_effect(fn, sync) {
  return internal_create_effect(PRE_EFFECT | MANAGED, fn, sync, current_block, true);
}
function pre_effect(fn) {
  if (current_effect === null) {
    throw new Error(
      "ERR_SVELTE_ORPHAN_EFFECT"
    );
  }
  const sync = current_effect !== null && (current_effect.f & RENDER_EFFECT) !== 0;
  return internal_create_effect(
    PRE_EFFECT,
    () => {
      const val = fn();
      flush_local_render_effects();
      return val;
    },
    sync,
    current_block,
    true
  );
}
function render_effect(fn, block = current_block, managed = false, sync = true) {
  let flags = RENDER_EFFECT;
  if (managed) {
    flags |= MANAGED;
  }
  return internal_create_effect(
    flags,
    /** @type {any} */
    fn,
    sync,
    block,
    true
  );
}
// @__NO_SIDE_EFFECTS__
function derived(fn) {
  const is_unowned = current_effect === null;
  const flags = is_unowned ? DERIVED | UNOWNED : DERIVED;
  const signal = (
    /** @type {import('../types.js').ComputationSignal<V>} */
    create_computation_signal(flags | CLEAN, UNINITIALIZED, current_block)
  );
  signal.i = fn;
  signal.e = default_equals;
  if (current_consumer !== null) {
    push_reference(current_consumer, signal);
  }
  return signal;
}
// @__NO_SIDE_EFFECTS__
function source(initial_value) {
  return create_source_signal(SOURCE | CLEAN, initial_value);
}
// @__NO_SIDE_EFFECTS__
function mutable_source(initial_value) {
  const s = /* @__PURE__ */ source(initial_value);
  s.e = safe_equal;
  if (current_component_context) {
    (current_component_context.d ?? (current_component_context.d = [])).push(s);
  }
  return s;
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
    // write version
    w: 0
  };
}
function flush_tasks() {
}
const IS_EFFECT = EFFECT | PRE_EFFECT | RENDER_EFFECT;
const FLUSH_MICROTASK = 0;
const FLUSH_SYNC = 1;
let current_scheduler_mode = FLUSH_MICROTASK;
let is_micro_task_queued = false;
let is_flushing_effect = false;
let current_queued_pre_and_render_effects = [];
let current_queued_effects = [];
let flush_count = 0;
let current_consumer = null;
let current_effect = null;
let current_dependencies = null;
let current_dependencies_index = 0;
let current_untracked_writes = null;
let current_untracking = false;
let ignore_mutation_validation = false;
let current_skip_consumer = false;
let current_block = null;
let current_component_context = null;
function is_runes(context) {
  const component_context = context || current_component_context;
  return component_context !== null && component_context.r;
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
        const is_unowned = (flags & UNOWNED) !== 0;
        const write_version = signal.w;
        const dep_write_version = dependency.w;
        if (is_unowned && dep_write_version > write_version) {
          signal.w = dep_write_version;
          return true;
        }
      }
    }
  }
  return false;
}
function execute_signal_fn(signal) {
  const init2 = signal.i;
  const flags = signal.f;
  const previous_dependencies = current_dependencies;
  const previous_dependencies_index = current_dependencies_index;
  const previous_untracked_writes = current_untracked_writes;
  const previous_consumer = current_consumer;
  const previous_block = current_block;
  const previous_component_context = current_component_context;
  const previous_skip_consumer = current_skip_consumer;
  const is_render_effect = (flags & RENDER_EFFECT) !== 0;
  const previous_untracking = current_untracking;
  current_dependencies = /** @type {null | import('./types.js').Signal[]} */
  null;
  current_dependencies_index = 0;
  current_untracked_writes = null;
  current_consumer = signal;
  current_block = signal.b;
  current_component_context = signal.x;
  current_skip_consumer = !is_flushing_effect && (flags & UNOWNED) !== 0;
  current_untracking = false;
  try {
    let res;
    if (is_render_effect) {
      res = /** @type {(block: import('./types.js').Block, signal: import('./types.js').Signal) => V} */
      init2(
        /** @type {import('./types.js').Block} */
        signal.b,
        /** @type {import('./types.js').Signal} */
        signal
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
      if (dependencies !== null) {
        const deps_length = dependencies.length;
        const full_current_dependencies = current_dependencies_index === 0 ? current_dependencies : dependencies.slice(0, current_dependencies_index).concat(current_dependencies);
        const current_dep_length = full_current_dependencies.length;
        const full_current_dependencies_set = current_dep_length > 16 && deps_length - current_dependencies_index > 1 ? new Set(full_current_dependencies) : null;
        for (i = current_dependencies_index; i < deps_length; i++) {
          const dependency = dependencies[i];
          if (full_current_dependencies_set !== null ? !full_current_dependencies_set.has(dependency) : !full_current_dependencies.includes(dependency)) {
            remove_consumer(signal, dependency);
          }
        }
      }
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
          const consumers = dependency.c;
          if (consumers === null) {
            dependency.c = [signal];
          } else if (consumers[consumers.length - 1] !== signal) {
            consumers.push(signal);
          }
        }
      }
    } else if (dependencies !== null && current_dependencies_index < dependencies.length) {
      remove_consumers(signal, current_dependencies_index);
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
function remove_consumer(signal, dependency) {
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
  if (consumers_length === 0 && (dependency.f & UNOWNED) !== 0) {
    set_signal_status(dependency, DIRTY);
    remove_consumers(
      /** @type {import('./types.js').ComputationSignal<V>} **/
      dependency,
      0
    );
  }
}
function remove_consumers(signal, start_index) {
  const dependencies = signal.d;
  if (dependencies !== null) {
    const active_dependencies = start_index === 0 ? null : dependencies.slice(0, start_index);
    let i;
    for (i = start_index; i < dependencies.length; i++) {
      const dependency = dependencies[i];
      if (active_dependencies === null || !active_dependencies.includes(dependency)) {
        remove_consumer(signal, dependency);
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
      destroy_signal(references[i]);
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
    flush_count = 0;
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
    const previously_flushing_effect = is_flushing_effect;
    is_flushing_effect = true;
    try {
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
    } finally {
      is_flushing_effect = previously_flushing_effect;
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
    const previously_flushing_effect = is_flushing_effect;
    try {
      is_flushing_effect = true;
      execute_effect(signal);
      set_signal_status(signal, CLEAN);
    } finally {
      is_flushing_effect = previously_flushing_effect;
    }
  } else {
    if (current_scheduler_mode === FLUSH_MICROTASK) {
      if (!is_micro_task_queued) {
        is_micro_task_queued = true;
        queueMicrotask(process_microtask);
      }
    }
    if ((flags & EFFECT) !== 0) {
      current_queued_effects.push(signal);
      if ((flags & MANAGED) === 0) {
        mark_subtree_children_inert(signal, true);
      }
    } else {
      const length = current_queued_pre_and_render_effects.length;
      let should_append = length === 0;
      if (!should_append) {
        const target_level = signal.l;
        const target_block = signal.b;
        const is_pre_effect = (flags & PRE_EFFECT) !== 0;
        let target_signal;
        let is_target_pre_effect;
        let i = length;
        while (true) {
          target_signal = current_queued_pre_and_render_effects[--i];
          if (target_signal.l <= target_level) {
            if (i + 1 === length) {
              should_append = true;
            } else {
              is_target_pre_effect = (target_signal.f & PRE_EFFECT) !== 0;
              if (target_signal.b !== target_block || is_target_pre_effect && !is_pre_effect) {
                i++;
              }
              current_queued_pre_and_render_effects.splice(i, 0, signal);
            }
            break;
          }
          if (i === 0) {
            current_queued_pre_and_render_effects.unshift(signal);
            break;
          }
        }
      }
      if (should_append) {
        current_queued_pre_and_render_effects.push(signal);
      }
    }
  }
}
function flush_local_render_effects() {
  const effects = [];
  for (let i = 0; i < current_queued_pre_and_render_effects.length; i++) {
    const effect = current_queued_pre_and_render_effects[i];
    if ((effect.f & RENDER_EFFECT) !== 0 && effect.x === current_component_context) {
      effects.push(effect);
      current_queued_pre_and_render_effects.splice(i, 1);
      i--;
    }
  }
  flush_queued_effects(effects);
}
function flush_local_pre_effects(context) {
  const effects = [];
  for (let i = 0; i < current_queued_pre_and_render_effects.length; i++) {
    const effect = current_queued_pre_and_render_effects[i];
    if ((effect.f & PRE_EFFECT) !== 0 && effect.x === context) {
      effects.push(effect);
      current_queued_pre_and_render_effects.splice(i, 1);
      i--;
    }
  }
  flush_queued_effects(effects);
}
function flushSync(fn) {
  flush_sync(fn);
}
function flush_sync(fn, flush_previous = true) {
  const previous_scheduler_mode = current_scheduler_mode;
  const previous_queued_pre_and_render_effects = current_queued_pre_and_render_effects;
  const previous_queued_effects = current_queued_effects;
  let result;
  try {
    infinite_loop_guard();
    const pre_and_render_effects = [];
    const effects = [];
    current_scheduler_mode = FLUSH_SYNC;
    current_queued_pre_and_render_effects = pre_and_render_effects;
    current_queued_effects = effects;
    if (flush_previous) {
      flush_queued_effects(previous_queued_pre_and_render_effects);
      flush_queued_effects(previous_queued_effects);
    }
    if (fn !== void 0) {
      result = fn();
    }
    if (current_queued_pre_and_render_effects.length > 0 || effects.length > 0) {
      flushSync();
    }
    flush_tasks();
    flush_count = 0;
  } finally {
    current_scheduler_mode = previous_scheduler_mode;
    current_queued_pre_and_render_effects = previous_queued_pre_and_render_effects;
    current_queued_effects = previous_queued_effects;
  }
  return result;
}
function update_derived(signal, force_schedule) {
  destroy_references(signal);
  const value = execute_signal_fn(signal);
  const status = (current_skip_consumer || (signal.f & UNOWNED) !== 0) && signal.d !== null ? MAYBE_DIRTY : CLEAN;
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
function get(signal) {
  const flags = signal.f;
  if ((flags & DESTROYED) !== 0) {
    return signal.v;
  }
  if (current_consumer !== null && (current_consumer.f & MANAGED) === 0 && !current_untracking) {
    const unowned = (current_consumer.f & UNOWNED) !== 0;
    const dependencies = current_consumer.d;
    if (current_dependencies === null && dependencies !== null && dependencies[current_dependencies_index] === signal && !(unowned && current_effect !== null)) {
      current_dependencies_index++;
    } else if (dependencies === null || current_dependencies_index === 0 || dependencies[current_dependencies_index - 1] !== signal) {
      if (current_dependencies === null) {
        current_dependencies = [signal];
      } else {
        current_dependencies.push(signal);
      }
    }
    if (current_untracked_writes !== null && current_effect !== null && (current_effect.f & CLEAN) !== 0 && (current_effect.f & MANAGED) === 0 && current_untracked_writes.includes(signal)) {
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
function mutate(source2, value) {
  set_signal_value(
    source2,
    untrack(() => get(source2))
  );
  return value;
}
function mark_subtree_children_inert(signal, inert, visited_blocks) {
  const references = signal.r;
  if (references !== null) {
    let i;
    for (i = 0; i < references.length; i++) {
      const reference = references[i];
      if ((reference.f & IS_EFFECT) !== 0) {
        mark_subtree_inert(reference, inert, visited_blocks);
      }
    }
  }
}
function mark_subtree_inert(signal, inert, visited_blocks = /* @__PURE__ */ new Set()) {
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
    const block = signal.b;
    if (block !== null && !visited_blocks.has(block)) {
      visited_blocks.add(block);
      const type = block.t;
      if (type === IF_BLOCK) {
        const condition_effect = block.e;
        if (condition_effect !== null && block !== current_block) {
          mark_subtree_inert(condition_effect, inert, visited_blocks);
        }
        const consequent_effect = block.ce;
        if (consequent_effect !== null && block.v) {
          mark_subtree_inert(consequent_effect, inert, visited_blocks);
        }
        const alternate_effect = block.ae;
        if (alternate_effect !== null && !block.v) {
          mark_subtree_inert(alternate_effect, inert, visited_blocks);
        }
      } else if (type === EACH_BLOCK) {
        const items = block.v;
        for (let { e: each_item_effect } of items) {
          if (each_item_effect !== null) {
            mark_subtree_inert(each_item_effect, inert, visited_blocks);
          }
        }
      }
    }
  }
  mark_subtree_children_inert(signal, inert, visited_blocks);
}
function mark_signal_consumers(signal, to_status, force_schedule) {
  const runes = is_runes(null);
  const consumers = signal.c;
  if (consumers !== null) {
    const length = consumers.length;
    let i;
    for (i = 0; i < length; i++) {
      const consumer = consumers[i];
      const flags = consumer.f;
      const unowned = (flags & UNOWNED) !== 0;
      if ((!force_schedule || !runes) && consumer === current_effect) {
        continue;
      }
      set_signal_status(consumer, to_status);
      const maybe_dirty = (flags & MAYBE_DIRTY) !== 0;
      if ((flags & CLEAN) !== 0 || maybe_dirty && unowned) {
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
  if (!current_untracking && !ignore_mutation_validation && current_consumer !== null && is_runes(null) && (current_consumer.f & DERIVED) !== 0) {
    throw new Error(
      "ERR_SVELTE_UNSAFE_MUTATION"
    );
  }
  if ((signal.f & SOURCE) !== 0 && !/** @type {import('./types.js').EqualsFunctions} */
  signal.e(value, signal.v)) {
    signal.v = value;
    signal.w++;
    if (is_runes(null) && !ignore_mutation_validation && current_effect !== null && current_effect.c === null && (current_effect.f & CLEAN) !== 0 && (current_effect.f & MANAGED) === 0) {
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
  remove_consumers(signal, 0);
  signal.i = signal.r = signal.y = signal.x = signal.b = signal.d = signal.c = null;
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
function untrack(fn) {
  const previous_untracking = current_untracking;
  try {
    current_untracking = true;
    return fn();
  } finally {
    current_untracking = previous_untracking;
  }
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
function push(props, runes = false, fn) {
  current_component_context = {
    // exports (and props, if `accessors: true`)
    x: null,
    // context
    c: null,
    // effects
    e: null,
    // mounted
    m: false,
    // parent
    p: current_component_context,
    // signals
    d: null,
    // props
    s: props,
    // runes
    r: runes,
    // update_callbacks
    u: null
  };
}
function pop(component) {
  const context_stack_item = current_component_context;
  if (context_stack_item !== null) {
    if (component !== void 0) {
      context_stack_item.x = component;
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
  return component || /** @type {T} */
  {};
}
function deep_read_state(value) {
  if (typeof value !== "object" || !value || value instanceof EventTarget) {
    return;
  }
  if (STATE_SYMBOL in value) {
    deep_read(value);
  } else if (!Array.isArray(value)) {
    for (let key in value) {
      const prop2 = value[key];
      if (typeof prop2 === "object" && prop2 && STATE_SYMBOL in prop2) {
        deep_read(prop2);
      }
    }
  }
}
function deep_read(value, visited = /* @__PURE__ */ new Set()) {
  if (typeof value === "object" && value !== null && // We don't want to traverse DOM elements
  !(value instanceof EventTarget) && !visited.has(value)) {
    visited.add(value);
    for (let key in value) {
      try {
        deep_read(value[key], visited);
      } catch (e) {
      }
    }
    const proto = Object.getPrototypeOf(value);
    if (proto !== Object.prototype && proto !== Array.prototype && proto !== Map.prototype && proto !== Set.prototype && proto !== Date.prototype) {
      const descriptors = get_descriptors(proto);
      for (let key in descriptors) {
        const get2 = descriptors[key].get;
        if (get2) {
          try {
            get2.call(value);
          } catch (e) {
          }
        }
      }
    }
  }
}
function unwrap(value) {
  if (is_signal(value)) {
    return get(value);
  }
  return value;
}
var node_prototype;
var element_prototype;
var text_prototype;
var map_prototype = Map.prototype;
var map_set_method = map_prototype.set;
var map_get_method = map_prototype.get;
var append_child_method;
var clone_node_method;
var first_child_get;
var next_sibling_get;
var text_content_set;
function init_operations() {
  if (node_prototype !== void 0) {
    return;
  }
  node_prototype = Node.prototype;
  element_prototype = Element.prototype;
  text_prototype = Text.prototype;
  append_child_method = node_prototype.appendChild;
  clone_node_method = node_prototype.cloneNode;
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
  // @ts-ignore
  get_descriptor(element_prototype, "className").set;
}
function append_child(element, child2) {
  append_child_method.call(element, child2);
}
function map_set(map, key, value) {
  map_set_method.call(map, key, value);
}
function map_get(map, key) {
  return map_get_method.call(map, key);
}
// @__NO_SIDE_EFFECTS__
function clone_node(node, deep) {
  return (
    /** @type {N} */
    clone_node_method.call(node, deep)
  );
}
function empty() {
  return document.createTextNode("");
}
// @__NO_SIDE_EFFECTS__
function child(node) {
  const child2 = first_child_get.call(node);
  return child2;
}
// @__NO_SIDE_EFFECTS__
function child_frag(node, is_text) {
  return first_child_get.call(
    /** @type {Node} */
    node
  );
}
// @__NO_SIDE_EFFECTS__
function sibling(node, is_text = false) {
  const next_sibling = next_sibling_get.call(node);
  return next_sibling;
}
function clear_text_content(node) {
  text_content_set.call(node, "");
}
// @__NO_SIDE_EFFECTS__
function create_element(name) {
  return document.createElement(name);
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
function reconcile_html(target, value, svg) {
  var html2 = value + "";
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
const EACH_ITEM_REACTIVE = 1;
const EACH_INDEX_REACTIVE = 1 << 1;
const EACH_KEYED = 1 << 2;
const EACH_IS_CONTROLLED = 1 << 3;
const EACH_IS_ANIMATED = 1 << 4;
const EACH_IS_STRICT_EQUALS = 1 << 6;
const PROPS_IS_IMMUTABLE = 1;
const PROPS_IS_RUNES = 1 << 1;
const PROPS_IS_UPDATED = 1 << 2;
const PROPS_IS_LAZY_INITIAL = 1 << 3;
const PassiveDelegatedEvents = ["touchstart", "touchmove", "touchend"];
const NEW_BLOCK = -1;
const MOVED_BLOCK = 99999999;
const LIS_BLOCK = -2;
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
      /** @type {import('../../types.js').Block} */
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
function create_each_item_block(item, index, key) {
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
    k: key,
    // item
    v: item,
    // parent
    p: (
      /** @type {import('../../types.js').EachBlock} */
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
function each(anchor_node, collection, flags, key_fn, render_fn, fallback_fn, reconcile_fn) {
  const block = create_each_block(flags, anchor_node);
  let current_fallback = null;
  let array;
  let keys = null;
  let render = null;
  block.r = /** @param {import('../../types.js').Transition} transition */
  (transition) => {
    const fallback = (
      /** @type {import('../../types.js').Render} */
      current_fallback
    );
    const transitions = fallback.s;
    transitions.add(transition);
    transition.f(() => {
      transitions.delete(transition);
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
    const effect = render_effect(
      () => {
        const dom = block.d;
        if (dom !== null) {
          remove(dom);
          block.d = null;
        }
        let anchor = block.a;
        const is_controlled = (block.f & EACH_IS_CONTROLLED) !== 0;
        if (is_controlled) {
          {
            anchor = empty();
            block.a.appendChild(anchor);
          }
        }
        fallback_fn(anchor);
        fallback.d = block.d;
        block.d = null;
      },
      block,
      true
    );
    fallback.e = effect;
    current_fallback = fallback;
  };
  const render_each = (block2) => {
    const flags2 = block2.f;
    const is_controlled = (flags2 & EACH_IS_CONTROLLED) !== 0;
    const anchor_node2 = block2.a;
    reconcile_fn(array, block2, anchor_node2, is_controlled, render_fn, flags2, true, keys);
  };
  const each2 = render_effect(
    () => {
      const maybe_array = collection();
      array = is_array(maybe_array) ? maybe_array : maybe_array == null ? [] : Array.from(maybe_array);
      if (key_fn !== null) {
        keys = array.map(key_fn);
      } else if ((flags & EACH_KEYED) === 0) {
        array.map(noop);
      }
      const length = array.length;
      if (fallback_fn !== null) {
        if (length === 0) {
          if (block.v.length !== 0 || render === null) {
            render_each(block);
            create_fallback_effect();
            return;
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
  render = render_effect(render_each, block, true);
  push_destroy_fn(each2, () => {
    const flags2 = block.f;
    const anchor_node2 = block.a;
    const is_controlled = (flags2 & EACH_IS_CONTROLLED) !== 0;
    let fallback = current_fallback;
    while (fallback !== null) {
      const dom = fallback.d;
      if (dom !== null) {
        remove(dom);
      }
      const effect = fallback.e;
      if (effect !== null) {
        destroy_signal(effect);
      }
      fallback = fallback.p;
    }
    reconcile_fn([], block, anchor_node2, is_controlled, render_fn, flags2, false, keys);
    destroy_signal(
      /** @type {import('../../types.js').EffectSignal} */
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
  var a_blocks = each_block.v;
  var active_transitions = each_block.s;
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
    for (; index < length; index++) {
      if (index >= a) {
        item = array[index];
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
  each_block.v = b_blocks;
}
function reconcile_tracked_array(array, each_block, dom, is_controlled, render_fn, flags, apply_transitions, keys) {
  var a_blocks = each_block.v;
  const is_computed_key = keys !== null;
  var active_transitions = each_block.s;
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
    var key;
    var item;
    var idx;
    b_blocks = Array(b);
    if (a === 0) {
      while (b > 0) {
        idx = b_end - --b;
        item = array[idx];
        key = is_computed_key ? keys[idx] : item;
        block = each_item_block(item, key, idx, render_fn, flags);
        b_blocks[idx] = block;
        insert_each_item_block(block, dom, is_controlled, null);
      }
    } else {
      var is_animated = (flags & EACH_IS_ANIMATED) !== 0;
      var should_update_block = (flags & (EACH_ITEM_REACTIVE | EACH_INDEX_REACTIVE)) !== 0 || is_animated;
      var start = 0;
      var sibling2 = null;
      item = array[b_end];
      key = is_computed_key ? keys[b_end] : item;
      outer:
        while (true) {
          while (a_blocks[a_end].k === key) {
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
            key = is_computed_key ? keys[b_end] : item;
          }
          item = array[start];
          key = is_computed_key ? keys[start] : item;
          while (start <= a_end && start <= b_end && a_blocks[start].k === key) {
            item = array[start];
            block = a_blocks[start];
            if (should_update_block) {
              update_each_item_block(block, item, start, flags);
            }
            b_blocks[start] = block;
            ++start;
            key = is_computed_key ? keys[start] : array[start];
          }
          break;
        }
      if (start > a_end) {
        while (b_end >= start) {
          item = array[b_end];
          key = is_computed_key ? keys[b_end] : item;
          block = each_item_block(item, key, b_end, render_fn, flags);
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
          key = is_computed_key ? keys[a] : item;
          map_set(item_index, key, a);
        }
        if (is_animated) {
          for (b = start; b <= a_end; ++b) {
            a = map_get(
              item_index,
              /** @type {V} */
              a_blocks[b].k
            );
            if (a !== void 0) {
              item = array[a];
              block = a_blocks[b];
              update_each_item_block(block, item, a, flags);
            }
          }
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
        var last_block;
        var last_sibling;
        var should_create;
        while (b_length-- > 0) {
          b_end = b_length + start;
          a = sources[b_length];
          should_create = a === -1;
          item = array[b_end];
          if (should_create) {
            key = is_computed_key ? keys[b_end] : item;
            block = each_item_block(item, key, b_end, render_fn, flags);
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
    /** @type {import('../../types.js').TemplateNode} */
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
    var transition;
    for (; i < length; i++) {
      block = active_transitions[i];
      transition = block.r;
      if (transition !== null) {
        block.r = null;
        destroy_each_item_block(block, null, false);
      }
    }
    active_transitions.length = 0;
  }
}
function update_each_item_block(block, item, index, type) {
  const block_v = block.v;
  if ((type & EACH_ITEM_REACTIVE) !== 0) {
    set_signal_value(block_v, item);
  }
  const transitions = block.s;
  const index_is_reactive = (type & EACH_INDEX_REACTIVE) !== 0;
  const each_animation = block.a;
  if (transitions !== null && (type & EACH_KEYED) !== 0 && each_animation !== null) {
    each_animation(block, transitions);
  }
  if (index_is_reactive) {
    set_signal_value(
      /** @type {import('../../types.js').Signal<number>} */
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
    for (let other of transitions) {
      if (other.r === "key") {
        transitions.delete(other);
      }
    }
    if (transitions.size === 0) {
      block.s = null;
    } else {
      trigger_transitions(transitions, "out");
      if (transition_block !== null) {
        transition_block.push(block);
      }
      return;
    }
  }
  const dom = block.d;
  if (!controlled && dom !== null) {
    remove(dom);
  }
  destroy_signal(
    /** @type {import('../../types.js').EffectSignal} */
    block.e
  );
}
function each_item_block(item, key, index, render_fn, flags) {
  const each_item_not_reactive = (flags & EACH_ITEM_REACTIVE) === 0;
  const item_value = each_item_not_reactive ? item : (flags & EACH_IS_STRICT_EQUALS) !== 0 ? /* @__PURE__ */ source(item) : /* @__PURE__ */ mutable_source(item);
  const index_value = (flags & EACH_INDEX_REACTIVE) === 0 ? index : /* @__PURE__ */ source(index);
  const block = create_each_item_block(item_value, index_value, key);
  const effect = render_effect(
    /** @param {import('../../types.js').EachItemBlock} block */
    (block2) => {
      render_fn(null, block2.v, block2.i);
    },
    block,
    true
  );
  block.e = effect;
  return block;
}
function trigger_transitions(transitions, target_direction, from) {
  const outros = [];
  for (const transition of transitions) {
    const direction = transition.r;
    const effect = transition.e;
    if (target_direction === "in") {
      if (direction === "in" || direction === "both") {
        transition.in();
      } else {
        transition.c();
      }
      transition.d.inert = false;
      mark_subtree_inert(effect, false);
    } else if (target_direction === "key") {
      if (direction === "key") {
        if (!transition.p) {
          transition.p = transition.i(
            /** @type {DOMRect} */
            from
          );
        }
        transition.in();
      }
    } else {
      if (direction === "out" || direction === "both") {
        if (!transition.p) {
          transition.p = transition.i();
        }
        outros.push(transition.o);
      }
      transition.d.inert = true;
      mark_subtree_inert(effect, true);
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
      /** @type {import('../../types.js').Block} */
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
function if_block(anchor_node, condition_fn, consequent_fn, alternate_fn) {
  const block = create_if_block();
  let consequent_dom = null;
  let alternate_dom = null;
  let has_mounted = false;
  let current_branch_effect = null;
  const if_effect = render_effect(
    () => {
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
        }
        has_mounted = true;
      }
    },
    block,
    false
  );
  const consequent_effect = render_effect(
    (_, consequent_effect2) => {
      const result = block.v;
      if (!result && consequent_dom !== null) {
        remove(consequent_dom);
        consequent_dom = null;
      }
      if (result && current_branch_effect !== consequent_effect2) {
        consequent_fn(anchor_node);
        current_branch_effect = consequent_effect2;
        consequent_dom = block.d;
      }
      block.d = null;
    },
    block,
    true
  );
  block.ce = consequent_effect;
  const alternate_effect = render_effect(
    (_, alternate_effect2) => {
      const result = block.v;
      if (result && alternate_dom !== null) {
        remove(alternate_dom);
        alternate_dom = null;
      }
      if (!result && current_branch_effect !== alternate_effect2) {
        if (alternate_fn !== null) {
          alternate_fn(anchor_node);
        }
        current_branch_effect = alternate_effect2;
        alternate_dom = block.d;
      }
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
const all_registerd_events = /* @__PURE__ */ new Set();
const root_event_handles = /* @__PURE__ */ new Set();
// @__NO_SIDE_EFFECTS__
function template(html2, return_fragment) {
  let cached_content;
  return () => {
    if (cached_content === void 0) {
      const content = create_fragment_from_html(html2);
      cached_content = return_fragment ? content : (
        /** @type {Node} */
        /* @__PURE__ */ child(content)
      );
    }
    return cached_content;
  };
}
function open_template(is_fragment, use_clone_node, anchor, template_element_fn) {
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
const comment_template = /* @__PURE__ */ template("<!>", true);
// @__NO_SIDE_EFFECTS__
function space(anchor) {
  return anchor;
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
    insert(current, null, anchor);
  }
  block.d = current;
}
function close(anchor, dom) {
  close_template(dom, false, anchor);
}
function close_frag(anchor, dom) {
  close_template(dom, true, anchor);
}
function event(event_name, dom, handler, capture, passive) {
  const options = {
    capture,
    passive
  };
  function target_handler(event2) {
    handle_event_propagation(dom, event2);
    if (!event2.cancelBubble) {
      return handler.call(this, event2);
    }
  }
  dom.addEventListener(event_name, target_handler, options);
  if (dom === document.body || dom === window || dom === document) {
    render_effect(() => {
      return () => {
        dom.removeEventListener(event_name, target_handler, options);
      };
    });
  }
}
function text_effect(dom, value) {
  render_effect(() => text(dom, value()));
}
function text(dom, value) {
  const prev_node_value = dom.__nodeValue;
  const next_node_value = stringify(value);
  if (prev_node_value !== next_node_value) {
    dom.nodeValue = next_node_value;
    dom.__nodeValue = next_node_value;
  }
}
function handle_event_propagation(handler_element, event2) {
  var _a;
  const owner_document = handler_element.ownerDocument;
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
    if (at_idx !== -1 && (handler_element === document || handler_element === /** @type {any} */
    window)) {
      event2.__root = handler_element;
      return;
    }
    const handler_idx = path.indexOf(handler_element);
    if (handler_idx === -1) {
      return;
    }
    if (at_idx <= handler_idx) {
      path_idx = at_idx + 1;
    }
  }
  current_target = /** @type {Element} */
  path[path_idx] || event2.target;
  define_property(event2, "currentTarget", {
    configurable: true,
    get() {
      return current_target || owner_document;
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
    if (event2.cancelBubble || parent_element === handler_element || current_target === handler_element) {
      break;
    }
    current_target = parent_element;
  }
  event2.__root = handler_element;
  current_target = handler_element;
}
function stringify(value) {
  return typeof value === "string" ? value : value == null ? "" : value + "";
}
function html(dom, get_value, svg) {
  let html_dom;
  let value;
  const effect = render_effect(() => {
    if (value !== (value = get_value())) {
      if (html_dom) {
        remove(html_dom);
      }
      html_dom = reconcile_html(dom, value, svg);
    }
  });
  push_destroy_fn(effect, () => {
    if (html_dom) {
      remove(html_dom);
    }
  });
}
function attr_effect(dom, attribute, value) {
  render_effect(() => {
    const string = value();
    attr(dom, attribute, string);
  });
}
function attr(dom, attribute, value) {
  value = value == null ? null : value + "";
  {
    if (value === null) {
      dom.removeAttribute(attribute);
    } else {
      dom.setAttribute(attribute, value);
    }
  }
}
const spread_props_handler = {
  get(target, key) {
    let i = target.props.length;
    while (i--) {
      let p = target.props[i];
      if (is_function(p))
        p = p();
      if (typeof p === "object" && p !== null && key in p)
        return p[key];
    }
  },
  getOwnPropertyDescriptor(target, key) {
    let i = target.props.length;
    while (i--) {
      let p = target.props[i];
      if (is_function(p))
        p = p();
      if (typeof p === "object" && p !== null && key in p)
        return get_descriptor(p, key);
    }
  },
  has(target, key) {
    for (let p of target.props) {
      if (is_function(p))
        p = p();
      if (key in p)
        return true;
    }
    return false;
  },
  ownKeys(target) {
    const keys = [];
    for (let p of target.props) {
      if (is_function(p))
        p = p();
      for (const key in p) {
        if (!keys.includes(key))
          keys.push(key);
      }
    }
    return keys;
  }
};
function spread_props(...props) {
  return new Proxy({ props }, spread_props_handler);
}
function mount(component, options) {
  init_operations();
  const anchor = empty();
  options.target.appendChild(anchor);
  return flush_sync(() => _mount(component, { ...options, anchor }), false);
}
function _mount(Component, options) {
  const registered_events = /* @__PURE__ */ new Set();
  const container = options.target;
  const block = create_root_block(options.intro || false);
  let component = void 0;
  const effect = render_effect(
    () => {
      if (options.context) {
        push({});
        current_component_context.c = options.context;
      }
      if (!options.props) {
        options.props = /** @type {Props} */
        {};
      }
      if (options.events) {
        options.props.$$events = options.events;
      }
      component = // @ts-expect-error the public typings are not what the actual function looks like
      Component(options.anchor, options.props) || {};
      if (options.context) {
        pop();
      }
    },
    block,
    true
  );
  block.e = effect;
  const bound_event_listener = handle_event_propagation.bind(null, container);
  const bound_document_event_listener = handle_event_propagation.bind(null, document);
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
        document.addEventListener(
          event_name,
          bound_document_event_listener,
          PassiveDelegatedEvents.includes(event_name) ? {
            passive: true
          } : void 0
        );
      }
    }
  };
  event_handle(array_from(all_registerd_events));
  root_event_handles.add(event_handle);
  mounted_components.set(component, () => {
    for (const event_name of registered_events) {
      container.removeEventListener(event_name, bound_event_listener);
    }
    root_event_handles.delete(event_handle);
    const dom = block.d;
    if (dom !== null) {
      remove(dom);
    }
    destroy_signal(
      /** @type {import('./types.js').EffectSignal} */
      block.e
    );
  });
  return component;
}
let mounted_components = /* @__PURE__ */ new WeakMap();
function unmount(component) {
  const fn = mounted_components.get(component);
  fn == null ? void 0 : fn();
}
async function append_styles(target, style_sheet_id, styles) {
  await Promise.resolve();
  const append_styles_to = get_root_for_style(target);
  if (!append_styles_to.getElementById(style_sheet_id)) {
    const style = /* @__PURE__ */ create_element("style");
    style.id = style_sheet_id;
    style.textContent = styles;
    append_child(
      /** @type {Document} */
      append_styles_to.head || append_styles_to,
      style
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
function prop(props, key, flags, initial) {
  var _a;
  var immutable = (flags & PROPS_IS_IMMUTABLE) !== 0;
  var runes = (flags & PROPS_IS_RUNES) !== 0;
  var prop_value = (
    /** @type {V} */
    props[key]
  );
  var setter = (_a = get_descriptor(props, key)) == null ? void 0 : _a.set;
  if (prop_value === void 0 && initial !== void 0) {
    if (setter && runes) {
      throw new Error(
        "ERR_SVELTE_BINDING_FALLBACK"
      );
    }
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
      props[key]
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
  var inner_current_value = /* @__PURE__ */ mutable_source(prop_value);
  var current_value = /* @__PURE__ */ derived(() => {
    var parent_value = getter();
    var child_value = get(inner_current_value);
    if (from_child) {
      from_child = false;
      return child_value;
    }
    return inner_current_value.v = parent_value;
  });
  if (!immutable)
    current_value.e = safe_equal;
  return function(value, mutation = false) {
    var current = get(current_value);
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
function init() {
  const context = (
    /** @type {import('./types.js').ComponentContext} */
    current_component_context
  );
  const callbacks = context.u;
  if (!callbacks)
    return;
  if (callbacks.b.length) {
    pre_effect(() => {
      observe_all(context);
      callbacks.b.forEach(run);
    });
  }
  user_effect(() => {
    const fns = untrack(() => callbacks.m.map(run));
    return () => {
      for (const fn of fns) {
        if (typeof fn === "function") {
          fn();
        }
      }
    };
  });
  if (callbacks.a.length) {
    user_effect(() => {
      observe_all(context);
      callbacks.a.forEach(run);
    });
  }
}
function observe_all(context) {
  if (context.d) {
    for (const signal of context.d)
      get(signal);
  }
  deep_read_state(context.s);
}
const set_getter = (object, key, getter) => {
  Object.defineProperty(object, key, {
    get: getter,
    enumerable: true,
    configurable: true
  });
};
const svelte = {
  set_getter,
  each_keyed,
  each_indexed,
  if_block,
  child,
  child_frag,
  sibling,
  pre_effect,
  render_effect,
  mutable_source,
  template,
  open,
  open_frag,
  space,
  comment,
  close,
  close_frag,
  event,
  text_effect,
  text,
  html,
  attr_effect,
  attr,
  spread_props,
  mount,
  unmount,
  append_styles,
  prop,
  init,
  get,
  set,
  mutate,
  untrack,
  push,
  pop,
  unwrap
};
export {
  svelte as default
};
