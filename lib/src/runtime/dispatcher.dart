import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:svelte/src/runtime/component.dart';
import 'package:svelte/src/runtime/utilities.dart';

typedef EventDispatcher<T> = void Function([T? detail]);

mixin Dispatcher on Component {
  final controllers = HashMap<String, StreamController<Object?>>();

  EventDispatcher<T> createEventDispatcher<T>(String type) {
    var controller = controllers[type];
    StreamSink<T> sink;

    if (controller == null) {
      var controller = StreamController<T>.broadcast(sync: true);
      controllers[type] = controller;
      sink = controller;
    } else {
      sink = unsafeCast<StreamSink<T>>(controller);
    }

    return ([T? detail]) {
      sink.add(unsafeCast<T>(detail));
    };
  }

  Stream<T> on<T>(String type) {
    var controller = unsafeCast<StreamController<T>>(controllers[type]);
    return controller.stream;
  }

  @mustCallSuper
  @override
  void onDestroy() {
    controllers.forEach((type, controller) {
      controller.close();
    });
  }
}
