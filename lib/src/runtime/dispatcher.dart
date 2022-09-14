import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:piko/dom.dart';

import 'package:piko/src/runtime/utilities.dart';

mixin Dispatcher {
  @internal
  @nonVirtual
  final StreamController<CustomEvent> controller = StreamController<CustomEvent>.broadcast(sync: true);

  @internal
  @nonVirtual
  final Map<String, Stream<CustomEvent>> eventTypeMap = HashMap<String, Stream<CustomEvent>>();

  @nonVirtual
  Stream<CustomEvent<T>> on<T>(String type) {
    var stream = eventTypeMap[type];

    if (stream == null) {
      stream = controller.stream.where((event) => event.type == type);
      eventTypeMap[type] = stream;
    }

    return unsafeCast<Stream<CustomEvent<T>>>(stream);
  }

  @nonVirtual
  void dispatch<T>(String type, {bool? cancelable, T? detail}) {
    controller.add(CustomEvent<T>(type, CustomEventOptions(detail: detail, cancelable: cancelable)));
  }
}
