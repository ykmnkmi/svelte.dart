// @dart=2.10

import 'component.dart';

class Scheduler {
  Scheduler()
      : dirtyFragments = <Fragment>[],
        resolvedFuture = Future<dynamic>.value(),
        updateScheduled = false,
        flushing = false;

  final List<Fragment> dirtyFragments;

  Future<dynamic> resolvedFuture;

  bool updateScheduled;

  bool flushing;

  void makeDirty(Fragment fragment, [String aspect]) {
    if (fragment.dirty.isEmpty) {
      dirtyFragments.add(fragment);
      scheduleUpdate();
    }

    fragment.dirty.add(aspect);
  }

  void scheduleUpdate() {
    if (!updateScheduled) {
      updateScheduled = true;
      resolvedFuture = resolvedFuture.then(flush);
    }
  }

  void flush([_]) {
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
    fragment.update(fragment.dirty);
    fragment.dirty.clear();
  }
}
