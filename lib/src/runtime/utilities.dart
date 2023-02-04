void noop() {
  // ...
}

String safe(Object? value) {
  return value == null ? '' : '$value';
}
