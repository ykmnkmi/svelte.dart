// ignore: library_prefixes
import 'dart:html';

import 'package:svelte_js/internal.dart' as $; // ignore: library_prefixes
import 'package:svelte_js/svelte_js.dart';

typedef AppFactory = ComponentFactory;

final AppFactory app = () {
  var $fragment = $.template('<img>');

  void app(Node $anchor, Object $properties, Object $events) {
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
