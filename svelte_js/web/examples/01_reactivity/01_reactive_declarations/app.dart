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

final _fragment = $.fragment('<button> </button> <p> </p> <p> </p>');

void _component(Node $anchor, AppProperties $properties) {
  $.push($properties, true);

  var count = $.mutableSource<int>(0);
  var doubled = $.mutableSource<int>();
  var quadrupled = $.mutableSource<int>();

  void handleClick(Event event) {
    $.set<int>(count, $.get<int>(count) + 1);
  }

  void app$preEffect() {
    $.get<int>(count);

    void doubled$untrack() {
      $.set<int>(doubled, $.get<int>(count) * 2);
    }

    $.untrack<void>(doubled$untrack);
  }

  $.preEffect(app$preEffect);

  void app1$preEffect() {
    $.get<int>(doubled);

    void quadrupled$untracked() {
      $.set<int>(quadrupled, $.get<int>(doubled) * 2);
    }

    $.untrack<void>(quadrupled$untracked);
  }

  $.preEffect(app1$preEffect);

  $.init();

  // Init
  var fragment = $.openFragment($anchor, true, _fragment);
  var button = $.childFragment<Element>(fragment);
  var text = $.child<Text>(button);
  var p = $.sibling<Element>($.sibling<Text>(button, true));
  var text1 = $.child<Text>(p);
  var p1 = $.sibling<Element>($.sibling<Text>(p, true));
  var text2 = $.child<Text>(p1);

  // Update
  void app$renderEffect() {
    $.text(text, 'Count: ${$.get<int>(count)}');
    $.text(text1, '${$.get<int>(count)} * 2 = ${$.get<int>(doubled)}');
    $.text(text2, '${$.get<int>(doubled)} * 2 = ${$.get<int>(quadrupled)}');
  }

  $.renderEffect(app$renderEffect);

  $.event('click', button, handleClick, false);
  $.closeFragment($anchor, fragment);
  $.pop();
}
