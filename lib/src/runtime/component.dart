import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:piko/src/runtime/fragment.dart';
import 'package:piko/src/runtime/scheduler.dart';

abstract class Component extends Fragment {
  @internal
  Set<String> dirty = HashSet<String>();

  @internal
  void markDirty(String name) {
    if (dirty.isEmpty) {
      scheduleUpdateFor(this);
    }

    dirty.add(name);
  }

  @internal
  void invalidate(String name, Object? oldValue, Object? newValue) {
    if (identical(oldValue, newValue)) {
      return;
    }

    markDirty(name);
  }
}
