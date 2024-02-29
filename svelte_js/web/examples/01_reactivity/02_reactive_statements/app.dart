import 'dart:js_interop';

import 'package:svelte_js/internal.dart' as $; // ignore: library_prefixes
import 'package:svelte_js/svelte_js.dart';
import 'package:web/web.dart';

extension type AppProperties._(JSObject object) implements JSObject {
  AppProperties() : object = JSObject();
}

extension type const App._(Component<AppProperties> component) {
  void call(Node node) {
    component(node, AppProperties());
  }
}

const App app = App._(_component);

final _template = $.template('<button> </button>');

void _component(Node $anchor, AppProperties $properties) {
  $.push($properties, true);

  var count = $.mutableSource<int>(0);

  void handleClick(Event event) {
    $.set<int>(count, $.get<int>(count) + 1);
  }

  $.preEffect(() {
    $.get<int>(count);

    $.untrack<void>(() {
      if ($.get<int>(count) > 10) {
        window.alert('count is dangerously high!');
        $.set<int>(count, 9);
      }
    });
  });

  $.init();

  /* Init */
  var button = $.open<Element>($anchor, true, _template);
  var text = $.child<Text>(button);

  /* Update */
  $.textEffect(text, () {
    return 'Clicked ${$.get<int>(count)} ${$.get<int>(count) == 1 ? 'time' : 'times'}';
  });

  $.event('click', button, handleClick, false);
  $.close($anchor, button);
  $.pop();
}
