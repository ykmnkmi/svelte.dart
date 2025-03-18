import 'dart:async';

import 'package:meta/meta.dart';
import 'package:svelte_runtime/src/dom/blocks/render.dart';
import 'package:svelte_runtime/src/dom/hydration.dart';
import 'package:svelte_runtime/src/reactivity.dart';
import 'package:svelte_runtime/src/runtime.dart';
import 'package:svelte_runtime/src/tasks.dart';
import 'package:svelte_runtime/src/unsafe_cast.dart';
import 'package:web/web.dart';

@optionalTypeArgs
typedef RenderValue<T> = void Function(Node anchor, Value<Object?> value);

@optionalTypeArgs
typedef RenderError = void Function(Node anchor, Value<Object?> ewrror);

enum AwaitState { pending, then, catch_ }

void awaitBlock<T>(
  Node node,
  FutureOr<T> Function() getInput, [
  Render? pendingRender,
  RenderValue? thenRender,
  RenderError? catchRender,
]) {
  if (hydrating) {
    hydrateNext<Node>();
  }

  Node anchor = node;

  ComponentContext? activeComponentContext = componentContext;

  FutureOr<Object?> input = T;

  Effect<void>? pendingEffect;

  Effect<void>? thenEffect;

  Effect<void>? catchEffect;

  LazySource<T> inputSource = createLazySource<T>();
  Source<Object?> errorSource = createSource<Object?>(null);
  bool resolved = false;

  Effect<void Function()?>? effect;

  void update(AwaitState state, bool restore) {
    resolved = true;

    if (restore) {
      setActiveEffect(effect);
      setActiveReaction(effect);
      setComponentContext(activeComponentContext);
    }

    try {
      if (state == AwaitState.pending && pendingRender != null) {
        if (pendingEffect != null) {
          resumeEffect(pendingEffect!);
        } else {
          pendingEffect = branch<void>(() {
            pendingRender(anchor);
          });
        }
      }

      if (state == AwaitState.then && thenRender != null) {
        if (thenEffect != null) {
          resumeEffect(thenEffect!);
        } else {
          thenEffect = branch<void>(() {
            thenRender(anchor, inputSource);
          });
        }
      }

      if (state == AwaitState.catch_ && catchRender != null) {
        if (catchEffect != null) {
          resumeEffect(catchEffect!);
        } else {
          catchEffect = branch<void>(() {
            catchRender(anchor, errorSource);
          });
        }
      }

      if (state != AwaitState.pending && pendingEffect != null) {
        pauseEffect(pendingEffect!, () {
          pendingEffect = null;
        });
      }

      if (state != AwaitState.then && thenEffect != null) {
        pauseEffect(thenEffect!, () {
          thenEffect = null;
        });
      }

      if (state != AwaitState.catch_ && catchEffect != null) {
        pauseEffect(catchEffect!, () {
          catchEffect = null;
        });
      }
    } finally {
      if (restore) {
        setComponentContext(null);
        setActiveReaction(null);
        setActiveEffect(null);

        // Without this, the DOM does not update until two ticks after the
        // future resolves, which is unexpected behaviour (and somewhat irksome
        // to test).
        flushSync();
      }
    }
  }

  effect = block<void Function()?>(() {
    if (input == (input = getInput())) {
      return null;
    }

    FutureOr<Object?> future = input;

    if (future is Future<T>) {
      resolved = false;

      future
          .then<void>((value) {
            if (future == input) {
              // We technically could check here since it's on the next
              // microtick but let's use internalSet for consistency and just to
              // be safe.
              inputSource.set(value, check: false);
              update(AwaitState.then, true);
            }
          })
          .catchError((Object error) {
            if (future == input) {
              // We technically could check here since it's on the next
              // microtick but let's use internalSet for consistency and just to
              // be safe.
              errorSource.set(error, check: false);
              update(AwaitState.catch_, true);

              if (catchRender == null) {
                // Rethrow the error if no catch block exists.
                throw errorSource.value!;
              }
            }
          });

      if (hydrating) {
        if (pendingRender != null) {
          pendingEffect = branch(() {
            pendingRender(anchor);
          });
        }
      } else {
        // Wait a microtask before checking if we should show the pending state as
        // the promise might have resolved by the next microtask.
        queueMicroTask(() {
          if (!resolved) {
            update(AwaitState.pending, true);
          }
        });
      }
    } else {
      inputSource.set(input as T, check: false);
      update(AwaitState.then, false);
    }

    // Set the input to something else, in order to disable the promise
    // callbacks.
    return () {
      input = T;
    };
  });

  if (hydrating) {
    anchor = unsafeCast<Node>(hydrateNode);
  }
}
