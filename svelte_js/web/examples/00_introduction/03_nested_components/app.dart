// ignore: library_prefixes
import 'dart:html';

import 'package:js/js_util.dart';
import 'package:svelte_js/internal.dart' as $; // ignore: library_prefixes
import 'package:svelte_js/svelte_js.dart';

import 'nested.dart';

typedef AppFactory = ComponentFactory;

final AppFactory app = () {
  var $fragment =
      $.template('<p class="svelte-urs9w7">These styles...</p> <!>', true);

  void app(Node $anchor, Object $properties, Object $events) {
    $.push($properties, false);

    /* Init */
    var fragment = $.openFragment<Node>($anchor, true, $fragment);
    var node = $.childFragment<Node>(fragment);
    var $nestedAnchor = $.sibling<Node>($.sibling<Node>(node));

    nested($nestedAnchor, newObject(), newObject());
    $.closeFragment($anchor, fragment);
    $.pop();
  }

  $.appendStyles(null, 'svelte-urs9w7', '''
\tp.svelte-urs9w7 {
\t\tcolor: purple;
\t\tfont-family: 'Comic Sans MS', cursive;
\t\tfont-size: 2em;
\t}
''');

  return app;
}();
