import 'package:svelte_runtime/reactivity.dart';
import 'package:svelte_runtime/runtime.dart';

void onMount<T>(T Function() callback) {
  if (componentContext == null) {
    throw StateError('ERR_LIFECYCLE_OUTSIDE_COMPONENT');
  }

  createUserEffect<void Function()?>(() {
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
