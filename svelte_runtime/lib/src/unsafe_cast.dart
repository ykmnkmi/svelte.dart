// JS interop casts only.
@pragma('dart2js:as:trust')
T unsafeCast<T>(Object? value) {
  return value as T;
}
