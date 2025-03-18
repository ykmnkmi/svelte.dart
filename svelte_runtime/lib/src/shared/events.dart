/// Subset of delegated events which should be passive by default.
///
/// These two are already passive via browser defaults on window, document and
/// body.
///
/// But since
/// - we're delegating them
/// - they happen often
/// - they apply to mobile which is generally less performant
/// we're marking them as passive by default for other elements, too.
const Set<String> passiveEvents = <String>{'touchstart', 'touchmove'};

/// Returns `true` if `name` is a passive event.
bool isPassiveEvent(String name) {
  return passiveEvents.contains(name);
}
