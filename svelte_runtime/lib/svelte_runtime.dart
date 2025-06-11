import 'package:svelte_runtime/src/reactivity.dart';
import 'package:svelte_runtime/src/runtime.dart';

export 'package:svelte_runtime/src/component.dart';
export 'package:svelte_runtime/src/dom.dart';
export 'package:svelte_runtime/src/reactivity.dart';
export 'package:svelte_runtime/src/render.dart';
export 'package:svelte_runtime/src/runtime.dart';

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
