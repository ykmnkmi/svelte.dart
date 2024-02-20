import 'dart:js_interop';

import 'package:svelte_js/internal.dart' as $; // ignore: library_prefixes
import 'package:svelte_js/svelte_js.dart';
import 'package:web/web.dart';

typedef AppFactory = ComponentFactory;

final AppFactory app = () {
  var $fragment = $.template('<img>');

  void app(Node $anchor, JSObject $properties) {
    $.push($properties, false);

    var src = '/tutorial/image.gif';
    var name = 'Rick Astley';
    /* Init */
    var img = $.open<Element>($anchor, true, $fragment);

    $.attr(img, 'src', src);
    $.attr(img, 'alt', '${$.stringify(name)} dancing');
    $.close($anchor, img);
    $.pop();
  }

  return app;
}();
