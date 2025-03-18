import 'package:svelte_runtime/src/reactivity.dart';
import 'package:svelte_runtime/src/runtime.dart';

export 'package:svelte_runtime/src/component.dart' show Component;
export 'package:svelte_runtime/src/effect.dart'
    show effectTracking, effect, effectPre, effectRoot;
export 'package:svelte_runtime/src/render.dart' show mount, unmount;
export 'package:svelte_runtime/src/signal.dart'
    show Derived, State, derived, lateState, state;

void onMount<T>(T Function() callback) {
  if (componentContext == null) {
    throw StateError('ERR_LIFECYCLE_OUTSIDE_COMPONENT');
  }

  userEffect<void Function()?>(() {
    T cleanUp = untrack<T>(callback);

    if (cleanUp is void Function()) {
      return cleanUp;
    }

    return null;
  });
}

void onDestroy(void Function() callback) {
  if (componentContext == null) {
    throw StateError('ERR_LIFECYCLE_OUTSIDE_COMPONENT');
  }

  onMount<void Function()>(() {
    return () {
      untrack<void>(callback);
    };
  });
}
