import 'dart:js_interop';

import 'package:svelte_js/internal.dart' as $; // ignore: library_prefixes
import 'package:svelte_js/svelte_js.dart';
import 'package:web/web.dart';

typedef Cat = ({String id, String name});

extension type AppProperties._(JSObject object) implements JSObject {
  AppProperties() : object = JSObject();
}

extension type const App._(Component<AppProperties> component) {
  void call(Node node) {
    component(node, AppProperties());
  }
}

const App app = App._(_component);

final _eachBlock =
    $.template('<li><a target="_blank" rel="noreferrer"> </a></li>');
// final _fragment = $.fragment('<h1>The Famous Cats of YouTube</h1> <ul></ul>');
final _fragment = $.fragment('<h1>...</h1> <ul></ul>');

void _component(Node $anchor, AppProperties $properties) {
  $.push($properties, false);

  var cats = $.mutableSource<List<Cat>>(<Cat>[
    (id: 'J---aiyznGQ', name: 'Keyboard Cat'),
    (id: 'z_AbfPXTKms', name: 'Maru'),
    (id: 'OUtn3pvWmpg', name: 'Henri The Existential Cat')
  ]);

  $.init();

  // Init
  var fragment = $.openFragment($anchor, true, _fragment);
  var h1 = $.childFragment<Element>(fragment);
  var ul = $.sibling<Element>($.sibling<Text>(h1, true));

  List<Cat> ul$each$collection() {
    return $.get<List<Cat>>(cats);
  }

  void ul$each$render(Node? $anchor, Signal<Cat> $item, int index) {
    String id() {
      return $.unwrap<Cat>($item).id;
    }

    String name() {
      return $.unwrap<Cat>($item).name;
    }

    // Init
    var li = $.open<Element>($anchor, true, _eachBlock);
    var a = $.child<Element>(li);
    var text = $.child<Text>(a);
    String? ahref;

    void ul$each$renderEffect() {
      if (ahref != (ahref = 'https://www.youtube.com/watch?v=${id()}')) {
        $.attr(a, 'href', ahref);
      }

      $.text(text, '${index + 1}: ${name()}');
    }

    $.renderEffect(ul$each$renderEffect);

    $.close($anchor, li);
  }

  $.eachIndexed(ul, ul$each$collection, 9, ul$each$render, null);

  $.closeFragment($anchor, fragment);
  $.pop();
}
