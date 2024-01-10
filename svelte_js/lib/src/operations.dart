@JS(r'$$')
library;

import 'dart:html';
import 'dart:js_util';

import 'package:js/js.dart';
import 'package:meta/dart2js.dart';

@JS('child')
external T child<T>(Node node);

@JS('child_frag')
external T childFragment<T>(Node node);

@JS('sibling')
external T sibling<T>(Node node);

@noInline
void listen<T extends Event>(
    Node node, String event, void Function(T) handler) {
  setProperty(node, '__$event', allowInterop(handler));
}
