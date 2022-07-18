import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:piko/dom.dart';
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

  void invalidate(String name, Object? oldValue, Object? newValue) {
    if (identical(oldValue, newValue)) {
      return;
    }

    markDirty(name);
  }
}

mixin EventDispatcher on Component {
  @internal
  final StreamController<CustomEvent> controller = StreamController<CustomEvent>();

  @internal
  final Map<String, Stream<CustomEvent>> typeMap = HashMap<String, Stream<CustomEvent>>();

  Stream<CustomEvent> on(String type) {
    return typeMap[type] ??= controller.stream.where((event) => event.type == type);
  }

  void dispatch<T>(String type, [T? detail]) {
    controller.add(CustomEvent<T>(type, CustomEventOptions<T>(detail: detail)));
  }
}
