import 'package:meta/meta.dart';
import 'package:svelte_runtime/src/animations.dart';
import 'package:svelte_runtime/src/dom/blocks/render.dart';
import 'package:svelte_runtime/src/dom/hydration.dart';
import 'package:svelte_runtime/src/dom/operations.dart';
import 'package:svelte_runtime/src/reactivity.dart';
import 'package:svelte_runtime/src/runtime.dart';
import 'package:svelte_runtime/src/shared.dart';
import 'package:svelte_runtime/src/tasks.dart';
import 'package:svelte_runtime/src/transition.dart';
import 'package:svelte_runtime/src/unsafe_cast.dart';
import 'package:web/web.dart';

@optionalTypeArgs
typedef Key<T> = Object Function(T item, int index);

@optionalTypeArgs
typedef RenderItem<T> = void Function(Node anchor, Value<T> item, int index);

@optionalTypeArgs
final class EachItem<T> {
  EachItem(this.index, this.key, this.valueSource, {this.previous, this.next});

  int index;

  Object key;

  Source<T> valueSource;

  AnimationManager? animationManager;

  late Effect<void> effect;

  EachItem<T>? previous;

  EachItem<T>? next;

  void move(EachItem<T>? next, Node anchor) {
    Node end = this.next != null
        ? unsafeCast<Node>(this.next!.effect.nodeStart)
        : anchor;

    Node destination = next != null
        ? unsafeCast<Node>(next.effect.nodeStart)
        : anchor;
    Node node = unsafeCast<Node>(effect.nodeStart);

    while (node != end) {
      Node nextNode = getNextSibling<Node>(node);
      before(destination, node);
      node = nextNode;
    }
  }

  void update(T value, int index, int type) {
    if (type & Each.itemReactive != 0) {
      if (!valueSource.equals(value)) {
        valueSource
          ..value = value
          ..markForCheck();
      }
    }

    if (type & Each.indexReactive != 0) {
      throw UnsupportedError('Reactive index.');
    } else {
      this.index = index;
    }
  }
}

@optionalTypeArgs
final class EachState<T> {
  EachState(this.flags) : items = <Object, EachItem<T>>{};

  int flags;

  EachItem<T>? first;

  Map<Object, EachItem<T>> items;

  void link(EachItem<T>? previous, EachItem<T>? next) {
    if (previous == null) {
      first = next;
    } else {
      previous.next = next;
      previous.effect.next = next?.effect;
    }

    if (next != null) {
      next.previous = previous;
      next.effect.previous = previous?.effect;
    }
  }
}

// The row of a keyed each block that is currently updating. We track this so
// that `animate:` directives have something to attach themselves to.
EachItem? currentEachItem;

int index(Object? item, int i) {
  return i;
}

// Pause multiple effects simultaneously, and coordinate their subsequent
// destruction. Used in each blocks.
void pauseEffects(
  EachState state,
  List<EachItem> items,
  Node? controlledAnchor,
  Map<Object, EachItem> itemsMap,
) {
  List<TransitionManager> transitions = <TransitionManager>[];
  int length = items.length;

  for (int i = 0; i < length; i++) {
    pauseChildren(items[i].effect, transitions, true);
  }

  bool isControlled =
      length > 0 && transitions.isEmpty && controlledAnchor != null;

  // If we have a controlled anchor, it means that the each block is inside a
  // single DOM element, so we can apply a fast-path for clearing the contents
  // of the element.
  if (isControlled) {
    Node parentNode = controlledAnchor.parentNode as Node;
    clearTextContent(parentNode);
    appendChild(parentNode, controlledAnchor);
    itemsMap.clear();
    state.link(items[0].previous, items[length - 1].next);
  }

  runOutTransitions(transitions, () {
    for (int i = 0; i < length; i++) {
      EachItem item = items[i];

      if (!isControlled) {
        itemsMap.remove(item.key);
        state.link(item.previous, item.next);
      }

      destroyEffect(item.effect, !isControlled);
    }
  });
}

void eachBlock<T>(
  Node node,
  int flags,
  List<T> Function() getCollection,
  Key<T> getKey,
  RenderItem<T> render, [
  Render? fallbackRender,
]) {
  Node anchor = node;

  EachState<T> state = EachState<T>(flags);

  bool isControlled = flags & Each.isControlled != 0;

  if (isControlled) {
    Node parentNode = node;

    anchor = hydrating
        ? setHydrateNode(getFirstChild(parentNode))
        : appendChild(parentNode, createText());
  }

  if (hydrating) {
    hydrateNext();
  }

  Effect? fallback;

  bool wasEmpty = false;

  block<void>(() {
    List<T> collection = getCollection();
    int length = collection.length;

    if (wasEmpty && length == 0) {
      // Ignore updates if the array is empty, and it already was empty on
      // previous run.
      return;
    }

    wasEmpty = length == 0;

    // `true` if there was a hydration mismatch.
    bool mismatch = false;

    if (hydrating) {
      Comment comment = unsafeCast<Comment>(anchor);
      bool isElse = comment.data == hydrationStart;

      if (isElse != (length == 0)) {
        // Hydration mismatch - remove the server-rendered DOM and start over.
        comment = removeNodes();
        setHydrateNode(comment);
        setHydrating(false);
        mismatch = true;
        anchor = comment;
      }
    }

    // This is separated to the previous block because `hydration` might change.
    if (hydrating) {
      EachItem<T>? previous;

      EachItem<T> item;

      for (int i = 0; i < length; i++) {
        Comment comment = unsafeCast<Comment>(hydrateNode);

        if (comment.nodeType == 8 && comment.data == hydrationEnd) {
          // The server rendered fewer items than expected, so break out and
          // continue appending non-hydrated items.
          anchor = comment;
          mismatch = true;
          setHydrating(false);
          break;
        }

        T value = collection[i];
        Object key = getKey(value, i);

        item = createItem<T>(
          comment,
          state,
          previous,
          null,
          value,
          key,
          i,
          render,
          flags,
          getCollection,
        );

        state.items[key] = item;
        previous = item;
      }

      // Remove excess nodes.
      if (length > 0) {
        setHydrateNode(removeNodes());
      }
    }

    if (!hydrating) {
      Effect effect = activeReaction as Effect;

      reconcile<T>(
        collection,
        state,
        anchor,
        render,
        flags,
        effect.flags & Flag.inert != 0,
        getKey,
        getCollection,
      );
    }

    if (fallbackRender != null) {
      if (length == 0) {
        if (fallback != null) {
          resumeEffect(fallback!);
        } else {
          fallback = branch<void>(() {
            fallbackRender(anchor);
          });
        }
      } else if (fallback != null) {
        pauseEffect(fallback!, () {
          fallback = null;
        });
      }
    }

    if (mismatch) {
      // Continue in hydration mode.
      setHydrating(true);
    }

    // When we mount the each block for the first time, the collection won't be
    // connected to this effect as the effect hasn't finished running yet and
    // its dependencies won't be assigned. However, it's possible that when
    // reconciling the each block that a mutation occurred and it's made the
    // collection `Flag.maybeDirty`, so reading the collection agai can provide
    // consistency to the reactive graph again as the deriveds will now be
    // `clean`.
    getCollection();
  });

  if (hydrating) {
    anchor = unsafeCast<Node>(hydrateNode);
  }
}

// Add, remove, or reorder items output by an each block as its input changes.
void reconcile<T>(
  List<T> list,
  EachState<T> state,
  Node anchor,
  RenderItem<T> render,
  int flags,
  bool isInert,
  Key<T> getKey,
  List<T> Function() getCollection,
) {
  bool isAnimated = (flags & Each.isAnimated) != 0;
  bool shouldUpdate = (flags & (Each.itemReactive | Each.indexReactive)) != 0;

  int length = list.length;
  Map<Object, EachItem<T>> items = state.items;
  EachItem<T>? first = state.first;
  EachItem<T>? current = first;

  Set<EachItem<T>>? seen;

  EachItem<T>? previous;

  Set<EachItem<T>>? toAnimate;

  List<EachItem<T>> matched = <EachItem<T>>[];

  List<EachItem<T>> stashed = <EachItem<T>>[];

  T value;

  Object key;

  EachItem<T>? item;

  int i;

  if (isAnimated) {
    for (i = 0; i < length; i++) {
      value = list[i];
      key = getKey(value, i);
      item = items[key];

      if (item != null) {
        item.animationManager?.measure();
        (toAnimate ??= <EachItem<T>>{}).add(item);
      }
    }
  }

  for (i = 0; i < length; i++) {
    value = list[i];
    key = getKey(value, i);
    item = items[key];

    if (item == null) {
      Node childAnchor = current == null ? anchor : current.effect.nodeStart!;

      previous = createItem<T>(
        childAnchor,
        state,
        previous,
        previous == null ? state.first : previous.next,
        value,
        key,
        i,
        render,
        flags,
        getCollection,
      );

      items[key] = previous;

      matched.clear();
      stashed.clear();

      current = previous.next;
      continue;
    }

    if (shouldUpdate) {
      item.update(value, i, flags);
    }

    Effect<void> effect = item.effect;

    if (effect.flags & Flag.inert != 0) {
      resumeEffect(effect);

      if (isAnimated) {
        item.animationManager?.unfix();
        (toAnimate ??= <EachItem<T>>{}).remove(item);
      }
    }

    if (item != current) {
      if (seen != null && seen.contains(item)) {
        if (matched.length < stashed.length) {
          EachItem<T> start = stashed.first;
          int j;

          previous = start.previous;

          EachItem<T> a = matched.first;
          EachItem<T> b = matched.last;

          for (j = 0; j < matched.length; j++) {
            matched[j].move(start, anchor);
          }

          for (j = 0; j < stashed.length; j++) {
            stashed[j].move(start, anchor);
          }

          state.link(a.previous, b.next);
          state.link(previous, a);
          state.link(b, start);

          current = start;
          previous = b;
          i--;

          matched.clear();
          stashed.clear();
        } else {
          // More efficient to move earlier items to the back.
          seen.remove(item);
          item.move(current, anchor);

          state.link(item.previous, item.next);
          state.link(item, previous == null ? state.first : previous.next);
          state.link(previous, item);

          previous = item;
        }

        continue;
      }

      matched.clear();
      stashed.clear();

      while (current != null && current.key != key) {
        // If the each block isn't inert and an item has an effect that is
        // already inert, skip over adding it to our seen Set as the item is
        // already being handled.
        if (isInert || current.effect.flags & Flag.inert == 0) {
          (seen ??= <EachItem<T>>{}).add(current);
        }

        stashed.add(current);
        current = current.next;
      }

      if (current == null) {
        continue;
      }

      item = current;
    }

    matched.add(item);
    previous = item;
    current = item.next;
  }

  if (current != null || seen != null) {
    List<EachItem<T>> toDestroy = <EachItem<T>>[...?seen];

    while (current != null) {
      // If the each block isn't inert, then inert effects are currently
      // outroing and will be removed once the transition is finished.
      if (isInert || current.effect.flags & Flag.inert == 0) {
        toDestroy.add(current);
      }

      current = current.next;
    }

    int length = toDestroy.length;

    if (length > 0) {
      Node? controlledAnchor;

      if (flags & Each.isControlled != 0 && length == 0) {
        controlledAnchor = anchor;
      }

      if (isAnimated) {
        for (i = 0; i < toDestroy.length; i++) {
          toDestroy[i].animationManager?.measure();
        }

        for (i = 0; i < toDestroy.length; i++) {
          toDestroy[i].animationManager?.fix();
        }
      }

      pauseEffects(state, toDestroy, controlledAnchor, items);
    }
  }

  if (isAnimated) {
    queueMicroTask(() {
      if (toAnimate == null) {
        return;
      }

      for (EachItem<T> item in toAnimate) {
        item.animationManager?.apply();
      }
    });
  }

  activeReaction as Effect
    ..first = state.first?.effect
    ..last = previous?.effect;
}

EachItem<T> createItem<T>(
  Node anchor,
  EachState<T> state,
  EachItem<T>? previous,
  EachItem<T>? next,
  T value,
  Object key,
  int index,
  RenderItem<T> render,
  int flags,
  List<T> Function() getCollection,
) {
  EachItem? previousEachItem = currentEachItem;

  bool reactive = flags & Each.itemReactive != 0;
  bool mutable = flags & Each.itemImmutable == 0;

  Source<T> valueSource;

  if (reactive) {
    // TODO(each): remove or ignore.
    // Dart version uses `State.update` for mutation.
    if (mutable) {
      throw UnsupportedError('Mutable values are not supported.');
    } else {
      valueSource = source<T>(value);
    }
  } else {
    throw UnsupportedError('Non-reactive values are not supported.');
  }

  if (flags & Each.indexReactive != 0) {
    throw UnsupportedError('message');
  }

  EachItem<T> item = EachItem<T>(
    index,
    key,
    valueSource,
    previous: previous,
    next: next,
  );

  currentEachItem = item;

  try {
    Effect<void> effect = branch<void>(() {
      render(anchor, valueSource, index);
    });

    effect.previous = previous?.effect;
    effect.next = next?.effect;
    item.effect = effect;

    if (previous == null) {
      state.first = item;
    } else {
      previous.next = item;
      previous.effect.next = item.effect;
    }

    if (next != null) {
      next.previous = item;
      next.effect.previous = item.effect;
    }

    return item;
  } finally {
    currentEachItem = previousEachItem;
  }
}
