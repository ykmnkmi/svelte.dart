import 'dart:js_interop';

import 'package:svelte_js/internal.dart' as $; // ignore: library_prefixes
import 'package:svelte_js/svelte_js.dart';
import 'package:web/web.dart';

import 'info.dart';

extension type AppProperties._(JSObject object) implements JSObject {
  AppProperties() : object = JSObject();
}

extension type const App._(Component<AppProperties> component) {
  void call(Node node) {
    component(node, AppProperties());
  }
}

const App app = App._(_component);

void _component(Node $anchor, AppProperties $properties) {
  $.push($properties, false);

  var properties = InfoProperties(
      name: 'svelte',
      version: 3,
      speed: 'blazing',
      website: 'https://svelte.dev');

  $.init();

  /* Init */
  var fragment = $.comment($anchor);
  var node = $.childFragment<Node>(fragment);

  info.component(node, $.spreadProperties(properties));
  $.closeFragment($anchor, fragment);
  $.pop();
}
