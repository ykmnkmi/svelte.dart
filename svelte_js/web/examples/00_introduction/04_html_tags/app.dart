// ignore: library_prefixes
import 'dart:html';

import 'package:svelte_js/internal.dart' as $; // ignore: library_prefixes
import 'package:svelte_js/svelte_js.dart';

typedef AppFactory = ComponentFactory;

final AppFactory app = () {
  var $fragment = $.template('<p><!></p>');

  void app(Node $anchor, Object $properties, Object $events) {
    $.push($properties, false);

    var string = "here's some <strong>HTML!!!</strong>";
    /* Init */
    var p = $.open<Node>($anchor, true, $fragment);
    var node = $.child<Text>(p);

    $.html(node, () => string, false);
    $.close($anchor, p);
    $.pop();
  }

  return app;
}();
