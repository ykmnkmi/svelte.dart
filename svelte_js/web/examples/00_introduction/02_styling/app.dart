import 'dart:js_interop';

import 'package:svelte_js/internal.dart' as $; // ignore: library_prefixes
import 'package:svelte_js/svelte_js.dart';
import 'package:web/web.dart';

typedef AppFactory = ComponentFactory;

final _$fragment = $.template('<p class="svelte-1xxr51v">Styled!</p>');

final AppFactory app = () {
  void app(Node $anchor, JSObject $properties) {
    $.push($properties, false);
    $.init();

    /* Init */
    var p = $.open<Element>($anchor, true, _$fragment);

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
