import 'package:svelte_runtime/src/reactivity.dart' as reactivity;

bool get effectTracking {
  return reactivity.effectTracking();
}

void effect<T>(T Function() callback) {
  reactivity.userEffect<T>(callback);
}

void effectPre<T>(T Function() callback) {
  reactivity.userPreEffect<T>(callback);
}

void Function() effectRoot<T>(T Function() callback) {
  return reactivity.effectRoot<T>(callback);
}
