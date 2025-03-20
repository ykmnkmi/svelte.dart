import 'package:svelte_runtime/src/reactivity/deriveds.dart';
import 'package:svelte_runtime/src/reactivity/flags.dart';
import 'package:svelte_runtime/src/reactivity/nodes.dart';
import 'package:svelte_runtime/src/reactivity/signals.dart';
import 'package:svelte_runtime/src/runtime.dart';
import 'package:svelte_runtime/src/transition.dart';

import '' as self;

typedef UnmountCallback = Future<void> Function([bool outro]);

void validateEffect(String name) {
  if (activeEffect == null && activeReaction == null) {
    throw StateError('ERR_EFFECT_ORPHAN');
  }

  if (activeReaction != null && activeReaction!.flags & Flag.unowned != 0) {
    throw StateError('ERR_EFFECT_IN_UNOWNED_DERIVED');
  }

  if (isDestroyingEffect) {
    throw StateError('ERR_EFFECT_IN_TEARDOWN');
  }
}

void pushEffect(Effect effect, Effect parent) {
  Effect? parentLast = parent.last;

  if (parentLast == null) {
    parent.last = parent.first = effect;
  } else {
    parentLast.next = effect;
    effect.previous = parentLast;
    parent.last = effect;
  }
}

Effect<T> createEffect<T>(
  int type,
  T Function()? callback,
  bool sync, [
  bool push = true,
]) {
  bool isRoot = type & Flag.rootEffect != 0;
  Effect? parent = activeEffect;

  Effect<T> effect = Effect<T>(
    flags: type | Flag.dirty,
    context: componentContext,
    callback: callback,
    parent: isRoot ? null : parent,
  );

  if (sync) {
    bool previouslyFlushingEffect = isFlushingEffect;

    try {
      setIsFlushingEffect(true);
      updateEffect(effect);
      effect.flags |= Flag.effectRan;
    } catch (_) {
      destroyEffect(effect);
      rethrow;
    } finally {
      setIsFlushingEffect(previouslyFlushingEffect);
    }
  } else if (callback != null) {
    scheduleEffect(effect);
  }

  bool inert =
      sync &&
      effect.dependencies == null &&
      effect.first == null &&
      effect.nodeStart == null &&
      effect.teardown == null &&
      effect.flags & Flag.effectHasDerived == 0;

  if (!inert && !isRoot && push) {
    if (parent != null) {
      pushEffect(effect, parent);
    }

    // if we're in a derived, add the effect there too.
    if (activeReaction is Derived) {
      assert(activeReaction!.flags & Flag.derived != 0);

      ((activeReaction as Derived).children ??= <Reaction>[]).add(effect);
    }
  }

  return effect;
}

// Internal representation of [effect.tracking].
bool effectTracking() {
  if (activeReaction == null) {
    return false;
  }

  // If it's skipped, that's because we're inside an unowned that is not being
  // tracked by another reaction.
  return !skipReaction;
}

Effect<T> teardown<T>(void Function() callback) {
  Effect<T> effect = createEffect<T>(Flag.renderEffect, null, false);
  setSignalStatus(effect, Flag.clean);
  effect.teardown = callback;
  return effect;
}

// Internal representation of `effect(...)`
Effect<T>? userEffect<T>(T Function() callback) {
  validateEffect('effect');

  // Non-nested `effect(...)` in a component should be deferred until the
  // component is mounted.
  bool defer =
      activeEffect != null &&
      activeEffect!.flags & Flag.branchEffect != 0 &&
      componentContext != null &&
      !componentContext!.mounted;

  if (defer) {
    ComponentContext context = componentContext!;

    (context.defferedEffects ??= <DefferedEffect>[]).add(
      DefferedEffect(callback, activeEffect, activeReaction),
    );

    return null;
  }

  return self.effect<T>(callback);
}

// Internal representation of [effect.pre].
Effect<T> userPreEffect<T>(T Function() callback) {
  validateEffect('effect.pre');
  return renderEffect<T>(callback);
}

// Internal representation of [effect.root].
void Function() effectRoot<T>(T Function() callback) {
  Effect<T> effect = createEffect<T>(Flag.rootEffect, callback, true);

  return () {
    destroyEffect(effect);
  };
}

// An effect root whose children can transition out.
Future<void> Function([bool outro]) componentRoot(
  void Function() Function() callback,
) {
  Effect<void> effect = createEffect<void>(Flag.rootEffect, callback, true);

  return ([bool outro = false]) {
    return Future<void>(() {
      if (outro) {
        pauseEffect(effect, () {
          destroyEffect(effect);
        });
      } else {
        destroyEffect(effect);
      }
    });
  };
}

Effect<T> effect<T>(T Function() callback) {
  return createEffect<T>(Flag.effect, callback, false);
}

Effect<T> renderEffect<T>(T Function() callback) {
  return createEffect<T>(Flag.renderEffect, callback, true);
}

Effect<void> templateEffect(void Function() callback) {
  return block<void>(callback);
}

Effect<T> block<T>(T Function() callback, [int flags = 0]) {
  return createEffect<T>(
    Flag.renderEffect | Flag.blockEffect | flags,
    callback,
    true,
  );
}

Effect<T> branch<T>(T Function() callback, [bool push = true]) {
  return createEffect<T>(
    Flag.renderEffect | Flag.branchEffect,
    callback,
    true,
    push,
  );
}

void executeEffectTeardown(Effect effect) {
  void Function()? teardown = effect.teardown;

  if (teardown != null) {
    bool previouslyDestroyingEffect = isDestroyingEffect;
    Reaction? previousReaction = activeReaction;
    setIsDestroyingEffect(true);
    setActiveReaction(null);

    try {
      teardown();
    } finally {
      setIsDestroyingEffect(previouslyDestroyingEffect);
      setActiveReaction(previousReaction);
    }
  }
}

void destroyEffectDeriveds(Effect effect) {
  List<Derived>? deriveds = effect.deriveds;

  if (deriveds != null) {
    effect.deriveds = null;

    for (int i = 0; i < deriveds.length; i++) {
      destroyDerived(deriveds[i]);
    }
  }
}

void destroyEffectChildren(Effect effect, [bool removeNodes = false]) {
  Effect? current = effect.first;
  effect.first = effect.last = null;

  while (current != null) {
    Effect? next = current.next;
    destroyEffect(current, removeNodes);
    current = next;
  }
}

void destroyBlockEffectChildren(Effect effect) {
  Effect? current = effect.first;

  while (current != null) {
    Effect? next = current.next;

    if (current.flags & Flag.branchEffect == 0) {
      destroyEffect(current);
    }

    current = next;
  }
}

void destroyEffect(Effect effect, [bool removeNodes = true]) {
  bool removed = false;

  if ((removeNodes || effect.flags & Flag.headEffect != 0) &&
      effect.nodeStart != null) {
    Node? node = effect.nodeStart;
    Node? end = effect.nodeEnd;

    while (node != null) {
      Node? next = node == end ? null : getNextSibling<Node?>(node);

      remove(node);
      node = next;
    }

    removed = true;
  }

  destroyEffectChildren(effect, removeNodes && !removed);
  destroyEffectDeriveds(effect);
  removeReactions(effect, 0);
  setSignalStatus(effect, Flag.destroyed);

  List<TransitionManager>? transitions = effect.transitions;

  if (transitions != null) {
    for (int i = 0; i < transitions.length; i++) {
      transitions[i].stop();
    }
  }

  executeEffectTeardown(effect);

  Effect? parent = effect.parent;

  // If the parent doesn't have any children, then skip this work altogether.
  if (parent != null && parent.first != null) {
    unlinkEffect(effect);
  }

  // `first` and `child` are nulled out in `destroyEffectChildren` we don't null
  // out `parent` so that error propagation can work correctly.
  effect
    ..next = null
    ..previous = null
    ..teardown = null
    ..context = null
    ..dependencies = null
    ..callback = null
    ..nodeStart = null
    ..nodeEnd = null;
}

// Detach an effect from the effect tree, freeing up memory and reducing the
// amount of work that happens on subsequent traversals.
void unlinkEffect(Effect effect) {
  Effect? parent = effect.parent;
  Effect? previous = effect.previous;
  Effect? next = effect.next;

  if (previous != null) {
    previous.next = next;
  }

  if (next != null) {
    next.previous = previous;
  }

  if (parent != null) {
    if (parent.first == effect) {
      parent.first = next;
    }

    if (parent.last == effect) {
      parent.last = previous;
    }
  }
}

// When a block effect is removed, we don't immediately destroy it or yank it
// out of the DOM, because it might have transitions. Instead, we 'pause' it.
// It stays around (in memory, and in the DOM) until outro transitions have
// completed, and if the state change is reversed then we _resume_ it.
// A paused effect does not update, and the DOM subtree becomes inert.
void pauseEffect(Effect effect, [void Function()? callback]) {
  List<TransitionManager> transitions = <TransitionManager>[];

  pauseChildren(effect, transitions, true);

  runOutTransitions(transitions, () {
    destroyEffect(effect);

    if (callback != null) {
      callback();
    }
  });
}

void runOutTransitions(
  List<TransitionManager> transitions,
  void Function() callback,
) {
  int remaining = transitions.length;

  if (remaining > 0) {
    void check() {
      if (--remaining == 0) {
        callback();
      }
    }

    for (int i = 0; i < transitions.length; i++) {
      transitions[i].exit(check);
    }
  } else {
    callback();
  }
}

void pauseChildren(
  Effect effect,
  List<TransitionManager> transitions,
  bool local,
) {
  if (effect.flags & Flag.inert == 0) {
    return;
  }

  effect.flags ^= Flag.inert;

  if (effect.transitions != null) {
    List<TransitionManager> effectTransitions = effect.transitions!;

    for (int i = 0; i < effectTransitions.length; i++) {
      TransitionManager transition = effectTransitions[i];

      if (transition.isGlobal || local) {
        transitions.add(transition);
      }
    }
  }

  Effect? child = effect.first;

  while (child != null) {
    Effect? sibling = child.next;
    bool transparent =
        child.flags & Flag.effectTransparent != 0 ||
        child.flags & Flag.branchEffect != 0;

    // TODO(effects) we don't need to call pause_children recursively with a
    //  linked list in place it's slightly more involved though as we have to
    //  account for `transparent` changing through the tree.
    pauseChildren(child, transitions, transparent ? local : false);
    child = sibling;
  }
}

// The opposite of [pauseEffect]. We call this if (for example) `x` becomes
// falsy then truthy: `{#if x}...{/if}`
void resumeEffect(Effect effect) {
  resumeChildren(effect, true);
}

void resumeChildren(Effect effect, bool local) {
  if (effect.flags & Flag.inert == 0) {
    return;
  }

  // If a dependency of this effect changed while it was paused, apply the
  // change now.
  if (checkDirtiness(effect)) {
    updateEffect(effect);
  }

  // Ensure we toggle the flag after possibly updating the effect so that
  // each block logic can correctly operate on inert items
  effect.flags ^= Flag.inert;

  Effect? child = effect.first;

  while (child != null) {
    Effect? sibling = child.next;
    bool transparent =
        child.flags & Flag.effectTransparent != 0 ||
        child.flags & Flag.branchEffect != 0;

    // TODO(effects): we don't need to call resume_children recursively with a
    //  linked list in place it's slightly more involved though as we have to
    //  account for `transparent` changing through the tree.
    resumeChildren(child, transparent ? local : false);
    child = sibling;
  }

  if (effect.transitions != null) {
    List<TransitionManager> transitions = effect.transitions!;

    for (int i = 0; i < transitions.length; i++) {
      TransitionManager transition = transitions[i];

      if (transition.isGlobal || local) {
        transition.enter();
      }
    }
  }
}
