import 'cast.vm.dart' if (dart.library.js) 'cast.js.dart' as implementation;

final T Function<T>(Object? object) cast = implementation.cast;
