import 'package:meta/dart2js.dart';
import 'package:meta/meta.dart';

@internal
@tryInline
@pragma('dart2js:as:trust')
T unsafeCast<T>(Object? value) {
  return value as T;
}
