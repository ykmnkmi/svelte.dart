import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:svelte_js/internal.dart' as $; // ignore: library_prefixes
import 'package:svelte_js/svelte_js.dart';
import 'package:web/web.dart';

typedef AppFactory = ComponentFactory;

final AppFactory app = () {
  var $fragment = $.template('<p> </p>');

  void app(Node $anchor, JSObject $properties) {
    $.push($properties, false);

    var name = 'world';
    /* Init */
    var p = $.open<Node>($anchor, true, $fragment);
    var text = $.child<Text>(p);

    text.setProperty('nodeValue'.toJS, 'Hello ${$.stringify(name)}!'.toJS);
    $.close($anchor, p);
    $.pop();
  }

  return app;
}();
