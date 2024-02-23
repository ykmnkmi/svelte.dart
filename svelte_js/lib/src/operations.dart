@JS(r'$$')
library;

import 'dart:js_interop';

import 'package:web/web.dart';

@JS('child')
external Node _child(Node node);

@pragma('dart2js:as:trust')
T child<T extends Node>(Node node) {
  return _child(node) as T;
}

@JS('child_frag')
external Node _childFragment(Node node, [bool isText]);

@pragma('dart2js:as:trust')
T childFragment<T extends Node>(Node node, [bool? isText]) {
  if (isText == null) {
    return _childFragment(node) as T;
  }

  return _childFragment(node, isText) as T;
}

@JS('sibling')
external Node _sibling(Node node);

@pragma('dart2js:as:trust')
T sibling<T extends Node>(Node node) {
  return _sibling(node) as T;
}
