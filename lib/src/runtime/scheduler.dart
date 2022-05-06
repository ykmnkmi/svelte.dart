import 'dart:async';

import 'package:piko/src/runtime/component.dart';

// naive implementation
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

  void scheduleUpdate(Fragment fragment) {
    dirtyFragments.add(fragment);

    if (!updateScheduled) {
      updateScheduled = true;
      resolvedFuture = resolvedFuture.then<void>((_) {
        flush();
      });
    }
  }

  void flush() {
    if (flushing) {
      return;
    }

    flushing = true;

    var fragments = dirtyFragments.toList();
    dirtyFragments.clear();

    for (var fragment in fragments) {
      update(fragment);
    }

    updateScheduled = false;
    flushing = false;
  }

  void update(Fragment fragment) {
    fragment
      ..update(fragment.dirty)
      ..dirty.clear();
  }
}
