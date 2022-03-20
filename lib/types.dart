extension ListExtensions<T> on List<T> {
  List<R> generate<R>(R Function(T) generator) {
    return List<R>.generate(length, (index) => generator(this[index]));
  }
}
