// TODO(flags): replace derived and effect flags with type checks
extension type const Flag._(int _) implements int {
  static const Flag derived = Flag._(1 << 1);
  static const Flag effect = Flag._(1 << 2);
  static const Flag renderEffect = Flag._(1 << 3);
  static const Flag blockEffect = Flag._(1 << 4);
  static const Flag branchEffect = Flag._(1 << 5);
  static const Flag rootEffect = Flag._(1 << 6);
  static const Flag boundaryEffect = Flag._(1 << 7);
  static const Flag unowned = Flag._(1 << 8);
  static const Flag disconnected = Flag._(1 << 9);
  static const Flag clean = Flag._(1 << 10);
  static const Flag dirty = Flag._(1 << 11);
  static const Flag maybeDirty = Flag._(1 << 12);
  static const Flag inert = Flag._(1 << 13);
  static const Flag destroyed = Flag._(1 << 14);
  static const Flag effectRan = Flag._(1 << 15);
  // 'Transparent' effects do not create a transition boundary
  static const Flag effectTransparent = Flag._(1 << 16);
  static const Flag headEffect = Flag._(1 << 19);
  static const Flag effectHasDerived = Flag._(1 << 20);
}
