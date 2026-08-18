import 'package:svelte_runtime/src/reactivity.dart' as reactivity;

typedef Prop<T> = T Function();

abstract interface class State<T> {
  T call();

  void set(T value);

  void update(void Function(T value) callback);
}

State<T> state<T>(T value) {
  return reactivity.createState<T>(value);
}

State<T> lateState<T>() {
  return reactivity.createLateState<T>();
}

abstract interface class Derived<T> {
  T call();
}

Derived<T> derived<T>(T Function() callback) {
  return reactivity.createDerived<T>(callback);
}

bool get effectTracking {
  return reactivity.effectTracking();
}

void effect<T>(T Function() callback) {
  reactivity.createUserEffect<T>(callback);
}

void effectPre<T>(T Function() callback) {
  reactivity.createUserEffectPre<T>(callback);
}

void Function() effectRoot<T>(T Function() callback) {
  return reactivity.effectRoot<T>(callback);
}
