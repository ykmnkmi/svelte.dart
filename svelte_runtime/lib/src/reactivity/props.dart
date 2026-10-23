import 'package:meta/meta.dart';
import 'package:svelte_runtime/src/runes.dart' as runes;

@optionalTypeArgs
final class BindableProp<T> extends Prop<T> implements runes.Bindable<T> {
  new(super.getter, this.setter);

  final void Function(T value) setter;

  @override
  void set(T value) {
    setter(value);
  }
}

@optionalTypeArgs
final class Prop<T> implements runes.Prop<T> {
  const new(this.getter);

  final T Function() getter;

  @override
  T call() {
    return getter();
  }
}

@optionalTypeArgs
final class DefaultProp<T> implements runes.Bindable<T> {
  const new(this.value);

  final T value;

  @override
  T call() {
    return value;
  }

  @override
  void set(T value) {}
}
