import 'dart:js_interop';

import 'package:svelte_js/internal.dart' as $; // ignore: library_prefixes
import 'package:svelte_js/svelte_js.dart';
import 'package:web/web.dart';

typedef NestedFactory = ComponentFactory;

final _$fragment = $.template("<p>...don't affect this element</p>");

void nested(Node $anchor, JSObject $properties) {
  $.push($properties, false);
  $.init();

  /* Init */
  var p = $.open<Element>($anchor, true, _$fragment);

  $.close($anchor, p);
  $.pop();
}
