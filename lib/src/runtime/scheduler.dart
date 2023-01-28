import 'package:svelte/src/runtime/utilities.dart';

Future<void> resolvedFuture = Future<void>(noop);

bool updateScheduled = false;

void scheduleUpdate() {
  if (updateScheduled) {
    return;
  }

  updateScheduled = true;
  resolvedFuture = Future<void>(flush);
}

Future<void> tick() {
  scheduleUpdate();
  return resolvedFuture;
}

void flush() {
  // ...
}
