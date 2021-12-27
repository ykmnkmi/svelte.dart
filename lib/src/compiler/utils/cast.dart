import 'cast.vm.dart' if (dart.library.js) 'cast.js.dart' as implementation;

T unsafeCast<T>(Object? object) {
  return implementation.cast<T>(object);
}
