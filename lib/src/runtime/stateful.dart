import 'dart:collection';

import 'package:meta/meta.dart';

import 'package:piko/src/runtime/component.dart';
import 'package:piko/src/runtime/fragment.dart';
import 'package:piko/src/runtime/scheduler.dart';

abstract class StatefulFragment implements Fragment {
  // TODO: use bitmask
  void update(Set<String> dirty) {}
}

abstract class StatefulComponent extends Component {
  @override
  StatefulFragment get fragment;

  // TODO: use bitmask
  @internal
  @nonVirtual
  Set<String> dirty = HashSet<String>();

  // TODO: use list
  @internal
  @nonVirtual
  Map<String, Object?> context = HashMap<String, Object?>();

  @internal
  @nonVirtual
  void markDirty(String name) {
    if (dirty.isEmpty) {
      scheduleUpdateFor(this);
    }

    dirty.add(name);
  }

  // TODO: use bitmask
  @internal
  @nonVirtual
  void invalidate(String name, Object? oldValue, Object? newValue) {
    if (identical(oldValue, newValue)) {
      return;
    }

    markDirty(name);
  }

  void beforeUpdate() {}

  void afterUpdate() {}
}
