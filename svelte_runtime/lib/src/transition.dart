abstract interface class TransitionManager {
  abstract bool isGlobal;

  // `in` is keyword.
  void enter();

  // `out` do not match with `enter`.
  void exit(void Function() check) {}

  void stop();
}
