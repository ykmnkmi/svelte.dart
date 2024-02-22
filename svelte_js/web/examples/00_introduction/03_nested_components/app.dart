import 'dart:js_interop';

import 'package:svelte_js/internal.dart' as $; // ignore: library_prefixes
import 'package:svelte_js/svelte_js.dart';
import 'package:web/web.dart';

import 'nested.dart';

typedef AppFactory = ComponentFactory;

final _$fragment =
    $.template('<p class="svelte-urs9w7">These styles...</p> <!>', true);

final AppFactory app = () {
  void app(Node $anchor, JSObject $properties) {
    $.push($properties, false);
    $.init();

    /* Init */
    var fragment = $.openFragment<Node>($anchor, true, _$fragment);
    var p = $.childFragment<Element>(fragment);
    var node = $.sibling<Node>($.sibling<Node>(p));

    nested(node, JSObject());
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
