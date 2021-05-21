int finish(int hash) {
  hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
  hash = hash ^ (hash >> 11);
  return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
}

int combine(int hash, int value) {
  hash = 0x1fffffff & (hash + value);
  hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
  return hash ^ (hash >> 6);
}

int hashObjects(Iterable<Object?> objects) {
  return finish(objects.fold(0, (int h, Object? i) => combine(h, i.hashCode)));
}

int hash2(Object? a, Object? b) {
  return finish(combine(combine(0, a.hashCode), b.hashCode));
}

int hash3(Object? a, Object? b, Object? c) {
  return finish(combine(combine(combine(0, a.hashCode), b.hashCode), c.hashCode));
}

int hash4(Object? a, Object? b, Object? c, Object? d) {
  return finish(combine(combine(combine(combine(0, a.hashCode), b.hashCode), c.hashCode), d.hashCode));
}
