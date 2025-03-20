import 'package:svelte_runtime/src/environment.dart';
import 'package:svelte_runtime/src/reactivity/effects.dart';
import 'package:svelte_runtime/src/reactivity/flags.dart';
import 'package:svelte_runtime/src/reactivity/signals.dart';
import 'package:svelte_runtime/src/runtime.dart';

bool updatingDerived = false;

Derived<T> createDerived<T>(T Function() callback) {
  int flags = Flag.derived | Flag.dirty;

  if (activeEffect == null) {
    flags |= Flag.unowned;
  } else {
    // Since deriveds are evaluated lazily, any effects created inside them are
    // created too late to ensure that the parent effect is added to the tree
    activeEffect!.flags |= Flag.effectHasDerived;
  }

  Derived? parentDerived;

  if (activeReaction is Derived) {
    assert(activeReaction!.flags & Flag.derived != 0);
    parentDerived = activeReaction as Derived;
  }

  Derived<T> derived = Derived<T>(
    flags: flags,
    context: componentContext,
    callback: callback,
    parent: parentDerived ?? activeEffect,
  );

  if (parentDerived != null) {
    List<Reaction>? children = parentDerived.children;

    if (children == null) {
      parentDerived.children = <Reaction>[derived];
    } else {
      children.add(derived);
    }
  }

  return derived;
}

void destroyDerivedChildren(Derived derived) {
  List<Reaction>? children = derived.children;

  if (children != null) {
    derived.children = null;

    for (int i = 0; i < children.length; i++) {
      Reaction child = children[i];

      if (child is Derived) {
        assert(child.flags & Flag.derived != 0);
        destroyDerived(child);
      } else {
        assert(child.flags & Flag.effect != 0);
        destroyEffect(child as Effect);
      }
    }
  }
}

// The currently updating deriveds, used to detect infinite recursion in dev.
// mode and provide a nicer error than 'too much recursion'.
List<Derived> stack = <Derived>[];

Effect? getDerivedParentEffect(Derived derived) {
  Reaction? parent = derived.parent;

  while (parent != null) {
    if (parent is Effect) {
      // Note: effect flag is zero too.
      assert(parent.flags & Flag.derived == 0);
      return parent;
    }

    parent = parent.parent;
  }

  return null;
}

T executeDerived<T>(Derived<T> derived) {
  T value;
  Effect? previousActiveEffect = activeEffect;

  setActiveEffect(getDerivedParentEffect(derived));

  try {
    if (assertionsEnabled) {
      if (stack.contains(derived)) {
        throw StateError('ERR_DERIVED_REFERENCES_SELF');
      }

      stack.add(derived);
    }

    destroyDerivedChildren(derived);
    value = updateReaction<T>(derived);
  } finally {
    setActiveEffect(previousActiveEffect);

    if (assertionsEnabled) {
      stack.removeLast();
    }
  }

  return value;
}

void updateDerived<T>(Derived<T> derived) {
  T value = executeDerived<T>(derived);

  int status =
      (skipReaction || derived.flags & Flag.unowned != 0) &&
              derived.dependencies != null
          ? Flag.maybeDirty
          : Flag.clean;

  setSignalStatus(derived, status);

  if (!derived.equals(value)) {
    derived.value = value;
    derived.version = incrementVersion();
  }
}

void destroyDerived(Derived derived) {
  destroyDerivedChildren(derived);
  removeReactions(derived, 0);
  setSignalStatus(derived, Flag.destroyed);

  derived
    ..untypedValue = #uninitialized
    ..reactions = null
    ..context = null
    ..dependencies = null
    ..children = null;
}
