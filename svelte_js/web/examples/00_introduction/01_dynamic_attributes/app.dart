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

final _template = $.template('<img>');

void _component(Node $anchor, AppProperties $properties) {
  $.push($properties, false);

  var src = '/tutorial/image.gif';
  var name = 'Rick Astley';

  $.init();

  /* Init */
  var img = $.open<Element>($anchor, true, _template);

  $.attr(img, 'src', src);
  $.attr(img, 'alt', '$name dancing');
  $.close($anchor, img);
  $.pop();
}
