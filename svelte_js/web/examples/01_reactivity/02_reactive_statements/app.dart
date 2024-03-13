// ignore_for_file: library_prefixes
library;

import 'dart:js_interop';

import 'package:svelte_js/internal.dart' as $;
import 'package:svelte_js/svelte_js.dart';
import 'package:web/web.dart';

extension type AppProperties._(JSObject _) implements JSObject {
  AppProperties() : _ = JSObject();
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

  void app$preEffect() {
    $.get<int>(count);

    void count$untrack() {
      if ($.get<int>(count) > 10) {
        window.alert('count is dangerously high!');
        $.set<int>(count, 9);
      }
    }

    $.untrack<void>(count$untrack);
  }

  $.preEffect(app$preEffect);

  $.init();

  // Init
  var button = $.open<Element>($anchor, true, _template);
  var text = $.child<Text>(button);

  // Update
  String text$textEffect() {
    return 'Clicked ${$.get<int>(count)} ${$.get<int>(count) == 1 ? 'time' : 'times'}';
  }

  $.textEffect(text, text$textEffect);
  $.event('click', button, handleClick, false);
  $.close($anchor, button);
  $.pop();
}
