import {
  // blocks/*.dart
  if as if_block,
  // operations.dart
  child, child_frag, sibling,
  // reactivity/computations.dart
  pre_effect, render_effect,
  // reactivity/sources.dart
  mutable_source,
  // render.dart
  template, open, open_frag, space, comment, close, close_frag, event, text_effect, text, html, attr, spread_props, mount, append_styles, unmount,
  // runtime.dart
  get, set, mutate, untrack, push, pop, prop, init,
} from 'svelte/internal';

export default {
  if_block,
  child, child_frag, sibling,
  pre_effect, render_effect,
  mutable_source,
  template, open, open_frag, space, comment, close, close_frag, event, text_effect, text, html, attr, spread_props, mount, append_styles, unmount,
  get, set, mutate, untrack, push, pop, prop, init,
};
