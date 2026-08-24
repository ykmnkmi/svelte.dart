import 'package:svelte_runtime/src/runes.dart' as runes;

final class Prop<T> implements runes.Prop<T> {
  const new(this.callback);

  final T Function() callback;

  @override
  T call() {
    return callback();
  }
}

final class ValueProp<T> implements runes.Prop<T> {
  const new(this.value);

  final T value;

  @override
  T call() {
    return value;
  }
}
