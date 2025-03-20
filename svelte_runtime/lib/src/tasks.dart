import 'dart:async';

bool isMicroTaskQueued = false;

bool isIdleTaskQueued = false;

List<void Function()> currentQueuedMicroTasks = <void Function()>[];

List<void Function()> currentQueuedIdleTasks = <void Function()>[];

void processMicroTasks() {
  isMicroTaskQueued = false;

  List<void Function()> tasks = currentQueuedMicroTasks;
  currentQueuedMicroTasks = <void Function()>[];

  for (int i = 0; i < tasks.length; i++) {
    tasks[i]();
  }
}

void processIdleTasks() {
  isIdleTaskQueued = false;

  List<void Function()> tasks = currentQueuedIdleTasks;
  currentQueuedIdleTasks = <void Function()>[];

  for (int i = 0; i < tasks.length; i++) {
    tasks[i]();
  }
}

void queueMicroTask(void Function() callback) {
  if (!isMicroTaskQueued) {
    isMicroTaskQueued = true;
    scheduleMicrotask(processMicroTasks);
  }

  currentQueuedMicroTasks.add(callback);
}

void queueIdleTask(void Function() callback) {
  if (!isIdleTaskQueued) {
    isIdleTaskQueued = true;
    scheduleMicrotask(processIdleTasks);
  }

  currentQueuedIdleTasks.add(callback);
}

// Synchronously run any queued tasks.
void flushTasks() {
  if (isMicroTaskQueued) {
    processMicroTasks();
  }

  if (isIdleTaskQueued) {
    processIdleTasks();
  }
}
