import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:piko/dom.dart';
import 'package:piko/src/runtime/component.dart';

mixin Dispatcher on Component {
  @internal
  @nonVirtual
  final StreamController<CustomEvent> controller = StreamController<CustomEvent>.broadcast(sync: true);

  @internal
  @nonVirtual
  final Map<String, Stream<CustomEvent>> typeMap = HashMap<String, Stream<CustomEvent>>();

  @nonVirtual
  Stream<CustomEvent<T>> on<T>(String type) {
    var stream = typeMap[type];

    if (stream == null) {
      typeMap[type] = stream = controller.stream.where((event) => event.type == type);
    }

    return stream.cast<CustomEvent<T>>();
  }

  @nonVirtual
  void dispatch<T>(String type, [T? detail]) {
    controller.add(CustomEvent<T>(type, CustomEventOptions<T>(detail: detail)));
  }
}
