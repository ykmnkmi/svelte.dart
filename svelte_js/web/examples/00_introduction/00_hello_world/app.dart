// ignore: library_prefixes
import 'dart:html';

import 'package:js/js_util.dart';
import 'package:svelte_js/internal.dart' as $; // ignore: library_prefixes
import 'package:svelte_js/svelte_js.dart';

typedef AppFactory = ComponentFactory;

final AppFactory app = () {
  var $fragment = $.template('<p> </p>');

  void app(Node $anchor, Object $properties, Object $events) {
    $.push($properties, false);

    var name = 'world';
    /* Init */
    var p = $.open<Node>($anchor, true, $fragment);
    var text = $.child<Text>(p);

    setProperty(text, 'nodeValue', 'Hello ${$.stringify(name)}!');
    $.close($anchor, p);
    $.pop();
  }

  return app;
}();
