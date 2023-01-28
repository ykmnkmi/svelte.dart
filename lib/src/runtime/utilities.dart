import 'package:meta/dart2js.dart';

void noop() {
  // ...
}

@tryInline
@pragma('dart2js:as:trust')
T unsafeCast<T extends Object?>(Object? object) {
  return object as T;
}
