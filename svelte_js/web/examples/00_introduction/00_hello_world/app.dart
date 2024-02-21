import 'dart:js_interop';

import 'package:svelte_js/internal.dart' as $; // ignore: library_prefixes
import 'package:svelte_js/svelte_js.dart';
import 'package:web/web.dart';

typedef AppFactory = ComponentFactory;

final _$fragment = $.template('<p> </p>');

void app(Node $anchor, JSObject $properties) {
  $.push($properties, false);

  var name = 'world';

  $.init();

  /* Init */
  var p = $.open<Node>($anchor, true, _$fragment);
  var text = $.child<Text>(p);

  $.nodeValue(text, 'Hello $name!');
  $.close($anchor, p);
  $.pop();
}
