extension type const Each._(int _) implements int {
  static const Each itemReactive = Each._(1);
  static const Each indexReactive = Each._(1 << 1);
  static const Each isControlled = Each._(1 << 2);
  static const Each isAnimated = Each._(1 << 3);
  static const Each itemImmutable = Each._(1 << 4);
}
