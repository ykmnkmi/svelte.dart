import 'package:meta/meta.dart' show optionalTypeArgs;
import 'package:svelte_runtime/src/reactivity/deriveds.dart';
import 'package:svelte_runtime/src/reactivity/flags.dart';
import 'package:svelte_runtime/src/reactivity/nodes.dart';
import 'package:svelte_runtime/src/runtime.dart';
import 'package:svelte_runtime/src/transition.dart';

abstract base class Signal {
  Signal({required this.flags, this.version = 0});

  int flags;

  int version;
}

void checkMutation(Value source) {
  if (activeReaction != null &&
      activeReaction!.flags & (Flag.derived | Flag.blockEffect) != 0 &&
      // If the source was created locally within the current derived, then we
      // allow the mutation.
      (derivedSources == null || !derivedSources!.contains(source))) {
    throw StateError('ERR_STATE_UNSAFE_MUTATION');
  }
}

@optionalTypeArgs
base mixin Value<T> on Signal {
  List<Reaction>? reactions;

  abstract T value;

  T call() {
    Value<T> self = this;

    int flags = self.flags;

    // If the derived is destroyed, just execute it again without retaining its
    // memoisation properties as the derived is stale.
    if (self is Derived<T> && flags & Flag.destroyed != 0) {
      assert(self.flags & Flag.derived != 0);

      T value = executeDerived<T>(self);
      // Ensure the derived remains destroyed.
      destroyDerived(self);
      return value;
    }

    if (capturedSignals != null) {
      capturedSignals!.add(self);
    }

    // Register the dependency on the current reaction signal.
    if (activeReaction != null) {
      if (derivedSources != null && derivedSources!.contains(self)) {
        throw StateError('ERR_STATE_UNSAFE_LOCAL_READ');
      }

      List<Value>? dependencies = activeReaction!.dependencies;

      if (newDependencies == null &&
          dependencies != null &&
          skippedDependencies < dependencies.length &&
          dependencies[skippedDependencies] == self) {
        skippedDependencies++;
      } else if (newDependencies == null) {
        newDependencies = <Value>[self];
      } else {
        newDependencies!.add(self);
      }

      if (untrackedWrites != null &&
          activeEffect != null &&
          activeEffect!.flags & Flag.clean != 0 &&
          activeEffect!.flags & Flag.branchEffect == 0 &&
          untrackedWrites!.contains(self)) {
        setSignalStatus(activeEffect!, Flag.dirty);
        scheduleEffect(activeEffect!);
      }
    } else if (self is Derived<T> && self.dependencies == null) {
      assert(self.flags & Flag.derived != 0);

      Derived derived = self;
      Reaction? parent = derived.parent;
      Derived target = derived;

      while (parent != null) {
        // Attach the derived to the nearest parent effect, if there are
        // deriveds in between then we also need to attach them too.
        if (parent is Derived) {
          assert(parent.flags & Flag.derived != 0);

          Derived parentDerived = parent;
          target = parentDerived;
          parent = parentDerived.parent;
        } else {
          Effect parentEffect = parent as Effect;
          List<Derived>? deriveds = parentEffect.deriveds;

          if (deriveds == null) {
            parentEffect.deriveds = <Derived>[target];
          } else if (!deriveds.contains(target)) {
            deriveds.add(target);
          }

          break;
        }
      }
    }

    if (self is Derived<T>) {
      if (checkDirtiness(self)) {
        updateDerived(self);
      }
    }

    return value;
  }

  bool equals(T value) {
    return this.value == value;
  }

  void markForCheck() {
    version = incrementVersion();
    markReactions(Flag.dirty);

    // If the current signal is running for the first time, it won't have any
    // reactions as we only allocate and assign the reactions after the signal
    // has fully executed. So in the case of ensuring it registers the reaction
    // properly for itself, we need to ensure the current effect actually gets
    // scheduled. i.e: `effect(() => x++)`
    if (activeEffect != null &&
        activeEffect!.flags & Flag.clean != 0 &&
        activeEffect!.flags & Flag.branchEffect == 0) {
      if (newDependencies != null && newDependencies!.contains(this)) {
        setSignalStatus(activeEffect!, Flag.dirty);
        scheduleEffect(activeEffect!);
      } else {
        if (untrackedWrites == null) {
          setUntrackedWrites(<Value>[this]);
        } else {
          untrackedWrites!.add(this);
        }
      }
    }
  }

  void markReactions(int status) {
    List<Reaction>? reactions = this.reactions;

    if (reactions == null) {
      return;
    }

    for (int i = 0; i < reactions.length; i++) {
      Reaction reaction = reactions[i];
      int flags = reaction.flags;

      if (flags & Flag.dirty != 0) {
        continue;
      }

      setSignalStatus(reaction, status);

      if (flags & (Flag.clean | Flag.unowned) != 0) {
        if (reaction is Derived) {
          assert(flags & Flag.derived != 0);
          reaction.markReactions(Flag.maybeDirty);
        } else {
          assert(flags & Flag.derived == 0);
          scheduleEffect(reaction as Effect);
        }
      }
    }
  }

  void set(T newValue, {bool check = true}) {
    if (check) {
      checkMutation(this);
    }

    if (equals(newValue)) {
      return;
    }

    value = newValue;
    markForCheck();
  }

  void update(void Function(T value) callback, {bool check = true}) {
    if (check) {
      checkMutation(this);
    }

    untrack<void>(() {
      callback(call());
    });

    markForCheck();
  }
}

@optionalTypeArgs
sealed class Reaction<T> extends Signal {
  Reaction({required super.flags, this.context, this.callback});

  ComponentContext? context;

  T Function()? callback;

  List<Value>? dependencies;

  Reaction? get parent;
}

@optionalTypeArgs
final class Derived<T> extends Reaction<T> with Value<T> {
  Derived({
    required super.flags,
    super.context,
    required super.callback,
    this.parent,
    this.untypedValue = #uninitialized,
  });

  Object? untypedValue;

  @override
  T get value {
    assert(untypedValue != #uninitialized);
    return untypedValue as T;
  }

  @override
  set value(T value) {
    untypedValue = value;
  }

  List<Reaction>? children;

  @override
  Reaction? parent;

  @override
  bool equals(T value) {
    return this.untypedValue == value;
  }
}

@optionalTypeArgs
final class Effect<T> extends Reaction<T> {
  Effect({
    required super.flags,
    super.context,
    required super.callback,
    required this.parent,
  });

  Node? nodeStart;

  Node? nodeEnd;

  List<Derived>? deriveds;

  void Function()? teardown;

  List<TransitionManager>? transitions;

  Effect? previous;

  Effect? next;

  Effect? first;

  Effect? last;

  @override
  Effect? parent;
}

final class Source<T> extends Signal with Value<T> {
  Source({required super.flags, required this.value});

  @override
  T value;
}

final class LazySource<T> extends Signal with Value<T> {
  LazySource({required super.flags}) : untypedValue = T;

  Object? untypedValue;

  @override
  T get value {
    assert(untypedValue != T, 'Uninitialized');
    return untypedValue as T;
  }

  @override
  set value(T value) {
    untypedValue = value;
  }

  @override
  bool equals(Object? value) {
    assert(untypedValue != T, 'Uninitialized');
    return untypedValue == value;
  }

  @override
  void set(T newValue, {bool check = true}) {
    if (check) {
      checkMutation(this);
    }

    if (untypedValue != newValue) {
      untypedValue = newValue;
      markForCheck();
    }
  }
}
