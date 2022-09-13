import 'package:meta/dart2js.dart';

@tryInline
@pragma('dart2js:as:trust')
T unsafeCast<T>(Object? object) {
  return object as T;
}
