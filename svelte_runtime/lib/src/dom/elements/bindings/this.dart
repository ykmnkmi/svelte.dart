import 'package:svelte_runtime/src/reactivity.dart';
import 'package:svelte_runtime/src/runtime.dart';
import 'package:svelte_runtime/src/tasks.dart';
import 'package:web/web.dart';

bool isBoundThis(HTMLElement? value, HTMLElement? element) {
  return value == element;
}

void bindThis<T extends HTMLElement>(
  T? element,
  T? Function() get,
  void Function(T?) set,
) {
  effect<void Function()>(() {
    List<Object>? oldParts;

    List<Object>? parts;

    renderEffect<void>(() {
      oldParts = parts;

      // We only track changes to the parts, not the value itself to avoid
      // unnecessary reruns.
      parts = <Object>[];

      untrack<void>(() {
        if (element != get(/* ...parts */)) {
          set(element /* , ...parts */);

          // If this is an effect rerun (cause: each block context changes),
          // then nullify the binding at the previous position if it isn't
          // already taken over by a different effect.
          if (oldParts != null &&
              isBoundThis(get(/* ...oldParts */), element)) {
            set(null /* , ...oldParts */);
          }
        }
      });
    });

    return () {
      // We can't use effects in the teardown phase, we we use a microtask
      // instead.
      queueMicroTask(() {
        if (parts != null && isBoundThis(get(/* ...parts */), element)) {
          set(null /* , ...parts */);
        }
      });
    };
  });
}
