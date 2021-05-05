import 'component.dart';

class Scheduler {
  Scheduler()
      : dirtyFragments = <Fragment>[],
        resolvedFuture = Future<void>.value(),
        updateScheduled = false,
        flushing = false;

  final List<Fragment> dirtyFragments;

  Future<void> resolvedFuture;

  bool updateScheduled;

  bool flushing;

  void makeDirty(Fragment fragment) {
    dirtyFragments.add(fragment);
    scheduleUpdate();
  }

  void scheduleUpdate() {
    if (!updateScheduled) {
      updateScheduled = true;
      resolvedFuture = resolvedFuture.then<void>((void _) {
        flush();
      });
    }
  }

  void flush() {
    if (flushing) {
      return;
    }

    flushing = true;

    do {
      for (final fragment in dirtyFragments) {
        update(fragment);
      }

      dirtyFragments.clear();
    } while (dirtyFragments.isNotEmpty);

    updateScheduled = false;
    flushing = false;
  }

  void update(Fragment fragment) {
    fragment.update();
  }
}
