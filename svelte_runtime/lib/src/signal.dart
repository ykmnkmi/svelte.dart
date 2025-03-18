import 'package:svelte_runtime/src/reactivity.dart' hide Derived;

abstract class State<T> {
  T call();

  void set(T value);

  void update(void Function(T value) callback);
}

State<T> state<T>(T value) {
  return createSource<T>(value);
}

State<T> lateState<T>() {
  return createLazySource<T>();
}

abstract interface class Derived<T> {
  T call();
}

Derived<T> derived<T>(T Function() callback) {
  return createDerived<T>(callback);
}
