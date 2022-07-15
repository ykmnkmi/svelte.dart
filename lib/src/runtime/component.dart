import 'dart:collection';

import 'package:piko/src/runtime/fragment.dart';
import 'package:piko/src/runtime/scheduler.dart';

abstract class Component extends Fragment {
  Set<String> dirty = HashSet<String>();

  void markDirty(String name) {
    if (dirty.isEmpty) {
      scheduleUpdateFor(this);
    }

    dirty.add(name);
  }

  void invalidate(String name, Object? oldValue, Object? newValue) {
    if (identical(oldValue, newValue)) {
      return;
    }

    markDirty(name);
  }
}
