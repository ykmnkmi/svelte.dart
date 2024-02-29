@JS(r'$$')
library;

import 'dart:js_interop';

import 'package:web/web.dart';

@JS('child')
external Node _child(Node node);

T child<T extends Node>(Node node) {
  return _child(node) as T;
}

@JS('child_frag')
external Node _childFragment(DocumentFragment fragment, [bool isText]);

T childFragment<T extends Node>(DocumentFragment fragment, [bool? isText]) {
  assert(fragment.nodeType == 11, 'Expected a DocumentFragment');

  if (isText == null) {
    return _childFragment(fragment) as T;
  }

  return _childFragment(fragment, isText) as T;
}

@JS('sibling')
external Node _sibling(Node node, [bool isText]);

T sibling<T extends Node>(Node node, [bool? isText]) {
  if (isText == null) {
    return _sibling(node) as T;
  }

  return _sibling(node, isText) as T;
}
