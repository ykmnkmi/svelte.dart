part of piko.runtime;

class Scheduler {
  bool updateScheduled = false;

  Future<void> resolvedFuture = Future<void>.value();

  void scheduleUpdate(Fragment<Component> fragment) {
    if (updateScheduled) {
      return;
    }

    updateScheduled = true;
  }
}
