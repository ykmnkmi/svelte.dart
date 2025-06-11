import 'dart:async';
import 'dart:math' as math;

import 'package:svelte_runtime/src/environment.dart';
import 'package:svelte_runtime/src/reactivity.dart';
import 'package:svelte_runtime/src/tasks.dart';

final class DefferedEffect {
  DefferedEffect(this.callback, [this.effect, this.reaction]);

  Object? Function() callback;

  Effect? effect;

  Reaction? reaction;
}

final class ComponentContext {
  ComponentContext({this.parent, this.mounted = false});

  ComponentContext? parent;

  Map<Object, Object>? context;

  List<DefferedEffect>? defferedEffects;

  bool mounted;
}

enum FlushMode { flushMicrotask, flushSync }

// Used for DEV time error handling.
Set<Object> handledErrors = <Object>{};

bool isThrowingError = false;

// Used for controlling the flush of effects.
FlushMode schedulerMode = FlushMode.flushMicrotask;

// Used for handling scheduling.
bool isMicrotaskQueued = false;

Effect? lastScheduledEffect;

bool isFlushingEffect = false;

bool isDestroyingEffect = false;

void setIsFlushingEffect(bool value) {
  isFlushingEffect = value;
}

void setIsDestroyingEffect(bool value) {
  isDestroyingEffect = value;
}

// Handle effect queues.

List<Effect> queuedRootEffects = <Effect>[];

int flushCount = 0;

List<Effect> effectStack = <Effect>[];

// Handle signal reactivity tree dependencies and reactions.

Reaction? activeReaction;

void setActiveReaction(Reaction? reaction) {
  activeReaction = reaction;
}

Effect? activeEffect;

void setActiveEffect(Effect? effect) {
  activeEffect = effect;
}

// When sources are created within a derived, we record them so that we can
// safely allow local mutations to these sources without the side-effect error
// being invoked unnecessarily.
List<Value>? derivedSources;

void setDerivedSources(List<Value>? sources) {
  derivedSources = sources;
}

// The dependencies of the reaction that is currently being executed. In many
// cases, the dependencies are unchanged between runs, and so this will be
// `null` unless and until a new dependency is accessed — we track this via
// `skipped_deps`.
List<Value>? newDependencies;

int skippedDependencies = 0;

// Tracks writes that the effect it's executed in doesn't listen to yet, so that
// the dependency can be added to the effect later on if it then reads it.
List<Value>? untrackedWrites;

void setUntrackedWrites(List<Value>? writes) {
  untrackedWrites = writes;
}

// Used by sources and deriveds for handling updates to unowned deriveds it
// starts from `1` to differentiate between a created effect and a run one for
// tracing.
int currentVersion = 1;

// If we are working with a [Value.call] chain that has no active container, to
// prevent memory leaks, we skip adding the reaction.
bool skipReaction = false;

// Handle collecting all signals which are read during a specific time frame.
Set<Value>? capturedSignals;

void setCapturedSignals(Set<Value>? signals) {
  capturedSignals = signals;
}

// Handling runtime component context
ComponentContext? componentContext;

void setComponentContext(ComponentContext? context) {
  componentContext = context;
}

int incrementVersion() {
  return ++currentVersion;
}

// Determines whether a derived or effect is dirty. If it is `Flags.maybeDirty`,
// will set the status to Flags.clean.
bool checkDirtiness(Reaction reaction) {
  int flags = reaction.flags;

  if (flags & Flag.dirty != 0) {
    return true;
  }

  if (flags & Flag.maybeDirty != 0) {
    List<Value>? dependencies = reaction.dependencies;
    bool isUnowned = flags & Flag.unowned != 0;

    if (dependencies != null) {
      bool isDisconnected = flags & Flag.disconnected != 0;
      bool isUnownedConnected =
          isUnowned && activeEffect != null && !skipReaction;
      int length = dependencies.length;

      // If we are working with a disconnected or an unowned signal that is now
      // connected (due to an active effect) then we need to re-connect the
      // reaction to the dependency.
      if (isDisconnected || isUnownedConnected) {
        for (int i = 0; i < length; i++) {
          Value dependency = dependencies[i];

          // We always re-add all reactions (even duplicates) if the derived was
          // previously disconnected.
          if (isDisconnected ||
              dependency.reactions == null ||
              !dependency.reactions!.contains(reaction)) {
            (dependency.reactions ??= <Reaction>[]).add(reaction);
          }
        }

        if (isDisconnected) {
          reaction.flags ^= Flag.disconnected;
        }
      }

      for (int i = 0; i < length; i++) {
        Value dependency = dependencies[i];

        // Only seriveds set dirty flag.
        if (dependency is Derived && checkDirtiness(dependency)) {
          updateDerived(dependency);
        }

        if (dependency.version > reaction.version) {
          return true;
        }
      }
    }

    // Unowned signals should never be marked as clean unless they are used
    // within an active_effect without skip_reaction.
    if (!isUnowned || (activeEffect != null && !skipReaction)) {
      setSignalStatus(reaction, Flag.clean);
    }
  }

  return false;
}

void propogateError(Object error, StackTrace stackTrace, Effect effect) {
  Effect? current = effect;

  while (current != null) {
    if (current.flags & Flag.boundaryEffect != 0) {
      try {
        (current.callback as void Function(Object?))(error);
        return;
      } catch (_) {
        current.flags ^= Flag.boundaryEffect;
      }
    }

    current = current.parent;
  }

  isThrowingError = false;
  Error.throwWithStackTrace(error, stackTrace);
}

bool shouldRethrowError(Effect effect) {
  return effect.flags & Flag.destroyed == 0 &&
      (effect.parent == null ||
          effect.parent!.flags & Flag.boundaryEffect == 0);
}

void resetIsThrowingError() {
  isThrowingError = false;
}

void handleError(
  Object error,
  StackTrace stackTrace,
  Effect effect,
  Effect? previousEffect,
  ComponentContext? componentContext,
) {
  if (isThrowingError) {
    if (previousEffect == null) {
      isThrowingError = false;
    }

    if (shouldRethrowError(effect)) {
      Error.throwWithStackTrace(error, stackTrace);
    }

    return;
  }

  if (previousEffect != null) {
    isThrowingError = true;
  }

  if (!assertionsEnabled ||
      componentContext == null ||
      handledErrors.contains(error)) {
    propogateError(error, stackTrace, effect);
    return;
  }

  // TODO(error): update error stack trace.

  handledErrors.add(error);
  propogateError(error, stackTrace, effect);

  if (shouldRethrowError(effect)) {
    Error.throwWithStackTrace(error, stackTrace);
  }
}

T updateReaction<T>(Reaction<T> reaction) {
  List<Value>? previousDependencies = newDependencies;
  int previousSkippedDependencies = skippedDependencies;
  List<Value>? previousUntrackedWrites = untrackedWrites;
  Reaction? previousReaction = activeReaction;
  bool previousSkipReaction = skipReaction;
  List<Value>? previousDerivedSources = derivedSources;
  ComponentContext? previousComponentContext = componentContext;
  int flags = reaction.flags;

  newDependencies = null;
  skippedDependencies = 0;
  untrackedWrites = null;

  activeReaction = flags & (Flag.branchEffect | Flag.rootEffect) == 0
      ? reaction
      : null;

  skipReaction = !isFlushingEffect && flags & Flag.unowned != 0;
  derivedSources = null;
  componentContext = reaction.context;

  try {
    T result = reaction.callback!();
    List<Value>? dependencies = reaction.dependencies;

    if (newDependencies != null) {
      removeReactions(reaction, skippedDependencies);

      if (dependencies != null && skippedDependencies > 0) {
        dependencies.addAll(newDependencies!);
      } else {
        reaction.dependencies = dependencies = newDependencies;
      }

      if (!skipReaction) {
        for (int i = skippedDependencies; i < dependencies!.length; i++) {
          (dependencies[i].reactions ??= <Reaction>[]).add(reaction);
        }
      }
    } else if (dependencies != null &&
        skippedDependencies < dependencies.length) {
      removeReactions(reaction, skippedDependencies);
      dependencies.length = skippedDependencies;
    }

    return result;
  } finally {
    newDependencies = previousDependencies;
    skippedDependencies = previousSkippedDependencies;
    untrackedWrites = previousUntrackedWrites;
    activeReaction = previousReaction;
    skipReaction = previousSkipReaction;
    derivedSources = previousDerivedSources;
    componentContext = previousComponentContext;
  }
}

void removeReaction(Reaction reaction, Value dependency) {
  List<Reaction>? reactions = dependency.reactions;

  if (reactions != null) {
    int index = reactions.indexOf(reaction);

    if (index != -1) {
      int newLength = reactions.length - 1;

      if (newLength == 0) {
        reactions = dependency.reactions = null;
      } else {
        // Swap with last element and then remove.
        reactions[index] = reactions[newLength];
        reactions.removeLast();
      }
    }
  }

  // If the derived has no reactions, then we can disconnect it from the graph,
  // allowing it to either reconnect in the future, or be GC'd by the VM.
  if (reactions == null &&
      dependency is Derived &&
      // Destroying a child effect while updating a parent effect can cause a
      // dependency to appear to be unused, when in fact it is used by the
      // currently-updating parent. Checking `newDependencies` allows us to skip
      // the expensive work of disconnecting and immediately reconnecting it.
      (newDependencies == null || !newDependencies!.contains(dependency))) {
    assert(dependency.flags & Flag.derived != 0);
    setSignalStatus(dependency, Flag.maybeDirty);

    // If we are working with a derived that is owned by an effect, then mark it
    // as being disconnected.
    if (dependency.flags & (Flag.unowned | Flag.disconnected) == 0) {
      dependency.flags ^= Flag.disconnected;
    }

    removeReactions(dependency, 0);
  }
}

void removeReactions(Reaction reaction, int startIndex) {
  List<Value>? dependencies = reaction.dependencies;

  if (dependencies == null) {
    return;
  }

  for (int i = startIndex; i < dependencies.length; i++) {
    removeReaction(reaction, dependencies[i]);
  }
}

void updateEffect(Effect effect) {
  int flags = effect.flags;

  if (flags & Flag.destroyed != 0) {
    return;
  }

  setSignalStatus(effect, Flag.clean);

  Effect? previousEffect = activeEffect;
  ComponentContext? previousComponentContext = componentContext;

  activeEffect = effect;

  try {
    if (flags & Flag.blockEffect != 0) {
      destroyBlockEffectChildren(effect);
    } else {
      destroyEffectChildren(effect);
    }

    destroyEffectDeriveds(effect);
    executeEffectTeardown(effect);

    Object? teardown = updateReaction<Object?>(effect);

    if (teardown is void Function()?) {
      effect.teardown = teardown;
    }

    effect.version = currentVersion;

    if (assertionsEnabled) {
      effectStack.add(effect);
    }
  } catch (error, stackTrace) {
    handleError(
      error,
      stackTrace,
      effect,
      previousEffect,
      previousComponentContext ?? effect.context,
    );
  } finally {
    activeEffect = previousEffect;
  }
}

void logEffectStack() {
  int length = effectStack.length;
  int start = math.max(0, length - 10);

  // ignore: avoid_print
  print('Last ten effects were:');

  for (int i = effectStack.length - 1; i >= start; i--) {
    // ignore: avoid_print
    print('${effectStack[i].callback}');
  }

  effectStack = <Effect>[];
}

void infiniteLoopGuard() {
  if (flushCount > 1000) {
    flushCount = 0;

    try {
      throw StateError('ERR_EFFECT_UPDATE_DEPTH_EXCEEDED');
    } catch (error, stackTrace) {
      // Try and handle the error so it can be caught at a boundary, that's if
      // there's an effect available from when it was last scheduled.
      if (lastScheduledEffect != null) {
        if (assertionsEnabled) {
          try {
            handleError(error, stackTrace, lastScheduledEffect!, null, null);
          } catch (error) {
            // Only log the effect stack if the error is re-thrown.
            logEffectStack();
            rethrow;
          }
        } else {
          handleError(error, stackTrace, lastScheduledEffect!, null, null);
        }
      } else {
        if (assertionsEnabled) {
          logEffectStack();
        }

        rethrow;
      }
    }
  }

  flushCount++;
}

void flushQueuedRootEffects(List<Effect> rootEffects) {
  int length = rootEffects.length;

  if (length == 0) {
    return;
  }

  infiniteLoopGuard();

  bool previouslyFlushingEffect = isFlushingEffect;
  isFlushingEffect = true;

  try {
    for (int i = 0; i < length; i++) {
      Effect effect = rootEffects[i];

      if (effect.flags & Flag.clean == 0) {
        effect.flags ^= Flag.clean;
      }

      List<Effect> collectedEffects = <Effect>[];
      processEffects(effect, collectedEffects);
      flushQueuedEffects(collectedEffects);
    }
  } finally {
    isFlushingEffect = previouslyFlushingEffect;
  }
}

void flushQueuedEffects(List<Effect> effects) {
  const int destroyedOrInert = Flag.destroyed | Flag.inert;

  int length = effects.length;

  if (length == 0) {
    return;
  }

  for (int i = 0; i < length; i++) {
    Effect effect = effects[i];

    if (effect.flags & destroyedOrInert == 0) {
      try {
        if (checkDirtiness(effect)) {
          updateEffect(effect);

          // Effects with no dependencies or teardown do not get added to the
          // effect tree. Deferred effects (e.g. `effect(...)`) _are_ added to the
          // tree because we don't know if we need to keep them until they are
          // executed. Doing the check here (rather than in `updateEffect`) allows
          // us to skip the work for immediate effects.
          if (effect.dependencies == null &&
              effect.first == null &&
              effect.nodeStart == null) {
            if (effect.teardown == null) {
              // Remove this effect from the graph.
              unlinkEffect(effect);
            } else {
              // Keep the effect in the graph, but free up some memory.
              effect.callback = null;
            }
          }
        }
      } catch (error, stackTrace) {
        handleError(error, stackTrace, effect, null, effect.context);
      }
    }
  }
}

void processDeffered() {
  isMicrotaskQueued = false;

  if (flushCount > 1001) {
    return;
  }

  List<Effect> previousQueuedRootEffects = queuedRootEffects;
  queuedRootEffects = <Effect>[];
  flushQueuedRootEffects(previousQueuedRootEffects);

  if (!isMicrotaskQueued) {
    flushCount = 0;
    lastScheduledEffect = null;

    if (assertionsEnabled) {
      effectStack = <Effect>[];
    }
  }
}

void scheduleEffect(Effect effect) {
  const int rootOrBranch = Flag.rootEffect | Flag.branchEffect;

  if (schedulerMode == FlushMode.flushMicrotask) {
    if (!isMicrotaskQueued) {
      isMicrotaskQueued = true;
      scheduleMicrotask(processDeffered);
    }
  }

  lastScheduledEffect = effect;

  Effect? current = effect;

  // TODO(runtime): reduce `!` checks.
  while (current!.parent != null) {
    current = current.parent!;

    int flags = current.flags;

    if (flags & rootOrBranch != 0) {
      if (flags & Flag.clean == 0) {
        return;
      }

      current.flags ^= Flag.clean;
    }
  }

  queuedRootEffects.add(current);
}

// This function both runs render effects and collects user effects in
// topological order from the starting effect passed in. Effects will be
// collected when they match the filtered bitwise flag passed in only. The
// collected effects array will be populated with all the user effects to be
// flushed.
void processEffects(Effect effect, List<Effect> collectedEffects) {
  Effect? currentEffect = effect.first;
  List<Effect> effects = <Effect>[];

  main_loop:
  while (currentEffect != null) {
    int flags = currentEffect.flags;
    bool isBranch = flags & Flag.branchEffect != 0;
    bool isSkippableBranch = isBranch && flags & Flag.clean != 0;
    Effect? sibling = currentEffect.next;

    if (!isSkippableBranch && flags & Flag.inert == 0) {
      if (flags & Flag.renderEffect != 0) {
        if (isBranch) {
          currentEffect.flags ^= Flag.clean;
        } else {
          try {
            if (checkDirtiness(currentEffect)) {
              updateEffect(currentEffect);
            }
          } catch (error, stackTrace) {
            handleError(error, stackTrace, effect, null, componentContext);
          }
        }

        Effect? child = currentEffect.first;

        if (child != null) {
          currentEffect = child;
          continue;
        }
      } else if (flags & Flag.effect != 0) {
        effects.add(currentEffect);
      }
    }

    if (sibling == null) {
      Effect? parent = currentEffect.parent;

      while (parent != null) {
        if (effect == parent) {
          break main_loop;
        }

        Effect? parentSibling = parent.next;

        if (parentSibling != null) {
          currentEffect = parentSibling;
          continue main_loop;
        }

        parent = parent.parent;
      }
    }

    currentEffect = sibling;
  }

  // We might be dealing with many effects here, far more than can be spread
  // into an array push call (callstack overflow). So let's deal with each
  // effect in a loop.
  for (int i = 0; i < effects.length; i++) {
    Effect child = effects[i];
    collectedEffects.add(child);
    processEffects(child, collectedEffects);
  }
}

// Internal version of `flushSync` with the option to not flush previous
// effects. Returns the result of the passed function, if given.
void flushSync([void Function()? callback]) {
  FlushMode previousSchedulerMode = schedulerMode;
  List<Effect> previousQueuedRootEffects = queuedRootEffects;

  try {
    infiniteLoopGuard();

    List<Effect> rootEffects = <Effect>[];

    schedulerMode = FlushMode.flushSync;
    queuedRootEffects = rootEffects;
    isMicrotaskQueued = false;

    flushQueuedRootEffects(previousQueuedRootEffects);

    if (callback != null) {
      callback();
    }

    flushTasks();

    if (queuedRootEffects.isNotEmpty || rootEffects.isNotEmpty) {
      flushSync();
    }

    flushCount = 0;
    lastScheduledEffect = null;

    if (assertionsEnabled) {
      effectStack = <Effect>[];
    }
  } finally {
    schedulerMode = previousSchedulerMode;
    queuedRootEffects = previousQueuedRootEffects;
  }
}

// Returns a promise that resolves once any pending state changes have been
// applied.
Future<void> tick() {
  return Future<void>(flushSync);
}

// When used inside a `derived()` or `effect()`, any state read inside
// `callback` will not be treated as a dependency.
T untrack<T>(T Function() callback) {
  Reaction? previousReaction = activeReaction;

  try {
    activeReaction = null;
    return callback();
  } finally {
    activeReaction = previousReaction;
  }
}

const int statusMask = ~(Flag.dirty | Flag.maybeDirty | Flag.clean);

void setSignalStatus(Signal signal, int status) {
  signal.flags = (signal.flags & statusMask) | status;
}

// Retrieves the context that belongs to the closest parent component with the
// specified `key`. Must be called during component initialisation.
T? getContext<T extends Object>([Object? key]) {
  assert(T != Object);

  Map<Object, Object> context = getOrInitContext();
  return context[key ?? T] as T;
}

// Associates an arbitrary `context` object with the current component and the
// specified `key` and returns that object. The context is then available to
// children of the component (including slotted content) with `getContext`.
// Like lifecycle functions, this must be called during component initialisation.
void setContext(Object key, Object value) {
  Map<Object, Object> context = getOrInitContext();
  context[key] = value;
}

// Checks whether a given `key` has been set in the context of a parent
// component. Must be called during component initialisation.
bool hasContext(Object key) {
  Map<Object, Object> context = getOrInitContext();
  return context.containsKey(key);
}

// Retrieves the whole context map that belongs to the closest parent component.
// Must be called during component initialisation. Useful, for example, if you
// programmatically create a component and want to pass the existing context to
// it.
Map<Object, Object> getAllContexts() {
  return getOrInitContext();
}

Map<Object, Object> getOrInitContext() {
  if (componentContext == null) {
    throw StateError('ERR_LIFECYCLE_OUTSIDE_COMPONENT');
  }

  return componentContext!.context ??= <Object, Object>{
    ...?getParentContext(componentContext!),
  };
}

Map<Object, Object>? getParentContext(ComponentContext componentContext) {
  ComponentContext? parent = componentContext.parent;

  while (parent != null) {
    Map<Object, Object>? context = parent.context;

    if (context != null) {
      return context;
    }

    parent = parent.parent;
  }

  return null;
}

void push() {
  componentContext = ComponentContext(parent: componentContext);
}

void pop() {
  ComponentContext? context = componentContext;

  if (context != null) {
    List<DefferedEffect>? defferedEffects = context.defferedEffects;

    if (defferedEffects != null) {
      Effect? previousEffect = activeEffect;
      Reaction? previousReaction = activeReaction;
      context.defferedEffects = null;

      try {
        for (int i = 0; i < defferedEffects.length; i++) {
          DefferedEffect componentEffect = defferedEffects[i];
          setActiveEffect(componentEffect.effect);
          setActiveReaction(componentEffect.reaction);
          effect(componentEffect.callback);
        }
      } finally {
        setActiveEffect(previousEffect);
        setActiveReaction(previousReaction);
      }
    }

    componentContext = context.parent;
    context.mounted = true;
  }
}
