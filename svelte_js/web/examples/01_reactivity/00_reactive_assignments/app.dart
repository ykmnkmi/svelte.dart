// ignore: library_prefixes
import 'dart:html';

import 'package:svelte_js/internal.dart' as $; // ignore: library_prefixes
import 'package:svelte_js/svelte_js.dart';

typedef AppFactory = ComponentFactory;

final AppFactory app = () {
  var $fragment = $.template('<button> </button>');

  void app(Node $anchor, Object $properties, Object $events) {
    $.push($properties, false);

    var count = $.mutableSource(0);

    void handleClick(Event event) {
      $.set(count, $.get(count) + 1);
    }

    /* Init */
    var button = $.open<Node>($anchor, true, $fragment);
    var text = $.child<Text>(button);

    /* Update */
    $.textEffect(text, () {
      return 'Clicked ${$.get(count)} ${$.get(count) == 1 ? 'time' : 'times'}';
    });
    $.listen(button, 'click', handleClick);
    $.close($anchor, button);
    $.pop();
  }

  $.delegate(['click']);
  return app;
}();
