@JS(r'$$')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:meta/dart2js.dart';
import 'package:web/web.dart';

@JS('child')
external T child<T extends JSObject>(Node node);

@JS('child_frag')
external T childFragment<T extends JSObject>(Node node);

@JS('sibling')
external T sibling<T extends JSObject>(Node node);

@noInline
void listen<T extends Event>(
    Node node, String event, void Function(T) handler) {
  node.setProperty('__$event'.toJS, handler.toJS);
}
