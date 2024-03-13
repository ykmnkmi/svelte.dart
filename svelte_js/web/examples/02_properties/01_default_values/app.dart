// ignore_for_file: library_prefixes
library;

import 'dart:js_interop';

import 'package:svelte_js/internal.dart' as $;
import 'package:svelte_js/svelte_js.dart';
import 'package:web/web.dart';

import 'nested.dart' as $$;

extension type AppProperties._(JSObject _) implements JSObject {
  AppProperties() : _ = JSObject();
}

extension type const App._(Component<AppProperties> component) {
  void call(Node node) {
    component(node, AppProperties());
  }
}

const App app = App._(_component);

final _fragment = $.fragment('<!> <!>');

void _component(Node $anchor, AppProperties $properties) {
  $.push($properties, false);
  $.init();

  // Init
  var fragment = $.openFragment($anchor, true, _fragment);
  var node = $.childFragment<Node>(fragment);
  var node1 = $.sibling<Node>($.sibling<Text>(node, true));

  $$.nested(node1, answer: 42);
  $$.nested(node1);
  $.closeFragment($anchor, fragment);
  $.pop();
}
