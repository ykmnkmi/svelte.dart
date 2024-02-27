import 'dart:js_interop';

import 'package:svelte_js/internal.dart' as $; // ignore: library_prefixes
import 'package:svelte_js/svelte_js.dart';
import 'package:web/web.dart';

typedef AppFactory = ComponentFactory;

final _$fragment = $.template('<button> </button>');

void app(Node $anchor, JSObject $properties) {
  $.push($properties, false);

  var count = $.mutableSource<int>(0);

  void handleClick(Event event) {
    $.set<int>(count, $.get<int>(count) + 1);
  }

  $.init();

  /* Init */
  var button = $.open<Element>($anchor, true, _$fragment);
  var text = $.child<Text>(button);

  /* Update */
  $.textEffect(text, () {
    return 'Clicked ${$.get<int>(count)} ${$.get<int>(count) == 1 ? 'time' : 'times'}';
  });

  $.event('click', button, handleClick, false);
  $.close($anchor, button);
  $.pop();
}
