import 'package:svelte_runtime/src/reactivity.dart' as reactivity;

abstract class State<T> {
  T call();

  void set(T value);

  void update(void Function(T value) callback);
}

State<T> state<T>(T value) {
  return reactivity.source<T>(value);
}

State<T> lateState<T>() {
  return reactivity.lazySource<T>();
}

abstract interface class Derived<T> {
  T call();
}

Derived<T> derived<T>(T Function() callback) {
  return reactivity.derived<T>(callback);
}
