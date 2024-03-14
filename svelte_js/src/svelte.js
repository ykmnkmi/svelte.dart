import {
  // blocks/*.dart
  each_keyed, each_indexed, if as if_block,
  // operations.dart
  child, child_frag, sibling,
  // reactivity/computations.dart
  pre_effect, render_effect,
  // reactivity/sources.dart
  mutable_source,
  // render.dart
  template, open, open_frag, space, comment, close, close_frag, event, text_effect, text, html, attr_effect, attr, spread_props, mount, unmount, append_styles, prop, init,
  // runtime.dart
  get, set, mutate, untrack, push, pop, unwrap,
} from 'svelte/internal';

const set_getter = (object, key, getter) => {
  Object.defineProperty(object, key, {
    get: getter,
    enumerable: true,
    configurable: true,
  });
};

export default {
  set_getter,
  each_keyed, each_indexed, if_block,
  child, child_frag, sibling,
  pre_effect, render_effect,
  mutable_source,
  template, open, open_frag, space, comment, close, close_frag, event, text_effect, text, html, attr_effect, attr, spread_props, mount, unmount, append_styles, prop, init,
  get, set, mutate, untrack, push, pop, unwrap,
};
