// ignore: library_prefixes
import 'dart:html';

import 'package:svelte_js/internal.dart' as $; // ignore: library_prefixes
import 'package:svelte_js/svelte_js.dart';

typedef AppFactory = ComponentFactory;

final AppFactory app = () {
  var $fragment = $.template('<p class="svelte-1xxr51v">Styled!</p>');

  void app(Node $anchor, Object $properties, Object $events) {
    $.push($properties, false);

    /* Init */
    var p = $.open<Element>($anchor, true, $fragment);

    $.close($anchor, p);
    $.pop();
  }

  $.appendStyles(null, 'svelte-1xxr51v', '''
\tp.svelte-1xxr51v {
\t\tcolor: purple;
\t\tfont-family: 'Comic Sans MS', cursive;
\t\tfont-size: 1.1em;
\t}
''');

  return app;
}();
