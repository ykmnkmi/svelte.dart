import 'dart:js_interop';

import 'package:svelte_js/internal.dart' as $; // ignore: library_prefixes
import 'package:svelte_js/svelte_js.dart';
import 'package:web/web.dart';

extension type AppProperties._(JSObject object) implements JSObject {
  AppProperties() : object = JSObject();
}

extension type const App._(Component<AppProperties> component) {
  void call(Node node) {
    component(node, AppProperties());
  }
}

const App app = App._(_component);

final _template = $.template('<p> </p>');

void _component(Node $anchor, AppProperties $properties) {
  $.push($properties, false);

  var name = 'world';

  $.init();

  /* Init */
  var p = $.open<Element>($anchor, true, _template);
  var text = $.child<Text>(p);

  $.nodeValue(text, 'Hello $name!');
  $.close($anchor, p);
  $.pop();
}