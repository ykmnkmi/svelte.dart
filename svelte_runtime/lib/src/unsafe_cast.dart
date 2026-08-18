// JS interop casts only.
@pragma('dart2js:as:trust')
@pragma('dart2js:tryInline')
T unsafeCast<T>(Object? value) {
  return value as T;
}
