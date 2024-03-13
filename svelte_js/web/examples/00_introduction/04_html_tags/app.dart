// ignore_for_file: library_prefixes
library;

import 'dart:js_interop';

import 'package:svelte_js/internal.dart' as $;
import 'package:svelte_js/svelte_js.dart';
import 'package:web/web.dart';

extension type AppProperties._(JSObject _) implements JSObject {
  AppProperties() : _ = JSObject();
}

extension type const App._(Component<AppProperties> component) {
  void call(Node node) {
    component(node, AppProperties());
  }
}

const App app = App._(_component);

final _template = $.template('<p><!></p>');

void _component(Node $anchor, AppProperties $properties) {
  $.push($properties, false);

  var string = "here's some <strong>HTML!!!</strong>";

  $.init();

  // Init
  var p = $.open<Node>($anchor, true, _template);
  var node = $.child<Text>(p);

  String node$html() {
    return string;
  }

  $.html(node, node$html, false);
  $.close($anchor, p);
  $.pop();
}
