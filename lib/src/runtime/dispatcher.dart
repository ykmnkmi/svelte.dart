import 'dart:async';
import 'dart:collection';
import 'dart:html';

import 'package:meta/meta.dart';

mixin Dispatcher {
  @internal
  @nonVirtual
  final StreamController<CustomEvent> controller = StreamController<CustomEvent>.broadcast(sync: true);

  @internal
  @nonVirtual
  final Map<String, Stream<CustomEvent>> eventTypeMap = HashMap<String, Stream<CustomEvent>>();

  @nonVirtual
  Stream<CustomEvent> on(String type) {
    var stream = eventTypeMap[type];

    if (stream == null) {
      stream = controller.stream.where((event) => event.type == type);
      eventTypeMap[type] = stream;
    }

    return stream;
  }

  @nonVirtual
  void dispatch(String type, {bool cancelable = true, Object? detail}) {
    controller.add(CustomEvent(type, detail: detail, cancelable: cancelable));
  }
}
