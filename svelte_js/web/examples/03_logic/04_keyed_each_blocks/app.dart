// ignore_for_file: library_prefixes
library;

import 'dart:js_interop';

import 'package:svelte_js/internal.dart' as $;
import 'package:svelte_js/svelte_js.dart';
import 'package:web/web.dart';

import 'thing.dart' as $$;

typedef Thing = ({int id, String color});

extension type AppProperties._(JSObject object) implements JSObject {
  AppProperties() : object = JSObject();
}

extension type const App._(Component<AppProperties> component) {
  void call(Node node) {
    component(node, AppProperties());
  }
}

const App app = App._(_component);

final _eachBlock = $.fragment(' <!>');
final _eachBlock1 = $.fragment(' <!>');
final _fragment = $.fragment(
    '<button>Remove first thing</button> <div style="display: grid; grid-template-columns: 1fr 1fr; grid-gap: 1em"><div><h2>Keyed</h2> <!></div> <div><h2>Unkeyed</h2> <!></div></div>');

void _component(Node $anchor, AppProperties $properties) {
  $.push($properties, false);

  var things = $.mutableSource<List<Thing>>(<Thing>[
    (id: 1, color: 'darkblue'),
    (id: 2, color: 'indigo'),
    (id: 3, color: 'deeppink'),
    (id: 4, color: 'salmon'),
    (id: 5, color: 'gold')
  ]);

  void handleClick(Event event) {
    $.set<List<Thing>>(things, $.get<List<Thing>>(things).sublist(1));
  }

  $.init();

  // Init
  var fragment = $.openFragment($anchor, true, _fragment);
  var button = $.childFragment<Element>(fragment);
  var div = $.sibling<Element>($.sibling<Text>(button, true));
  var div$1 = $.child<Element>(div);
  var h2 = $.child<Element>(div$1);
  var node = $.sibling<Element>($.sibling<Text>(h2, true));
  var div$2 = $.sibling<Element>($.sibling<Text>(div$1, true));
  var h2$1 = $.child<Element>(div$2);
  var node2 = $.sibling($.sibling(h2$1, true));
  $.event('click', button, handleClick, false);

  List<Thing> node$each$collection() {
    return $.get<List<Thing>>(things);
  }

  Object node$each$key(Thing thing, int index, List<Thing> list) {
    return thing.id;
  }

  void node$each$render(
      Node? $anchor, MaybeSignal<Thing> thing, MaybeSignal<int> index) {
    // Init
    var fragment1 = $.openFragment($anchor, true, _eachBlock);
    var text = $.childFragment<Text>(fragment1, true);
    var node1 = $.sibling<Node>(text);

    // Update
    String app$textEffect() {
      return '${$.unwrap<int>(index)}: ';
    }

    $.textEffect(text, app$textEffect);

    var thing$properties = $$.ThingProperties.js();

    String thing$properties$current() {
      return $.unwrap<Thing>(thing).color;
    }

    $.setGetter(thing$properties, 'current', thing$properties$current);
    $$.thing.component(node1, thing$properties);

    $.closeFragment($anchor, fragment1);
  }

  $.eachKeyed(
    node,
    node$each$collection,
    7,
    node$each$key,
    node$each$render,
    null,
  );

  List<Thing> node2$each$collection() {
    return $.get<List<Thing>>(things);
  }

  void node2$each$render(Node? $anchor, MaybeSignal<Thing> thing, int index) {
    // Init
    var fragment2 = $.openFragment($anchor, true, _eachBlock1);
    var text1 = $.childFragment<Text>(fragment2, true);
    $.nodeValue(text1, '$index');

    var node3 = $.sibling<Node>(text1);

    var thing$properties = $$.ThingProperties.js();

    String thing$properties$current() {
      return $.unwrap<Thing>(thing).color;
    }

    $.setGetter(thing$properties, 'current', thing$properties$current);
    $$.thing.component(node3, thing$properties);

    $.closeFragment($anchor, fragment2);
  }

  $.eachIndexed(
    node2,
    node2$each$collection,
    1,
    node2$each$render,
    null,
  );

  $.closeFragment($anchor, fragment);
  $.pop();
}
