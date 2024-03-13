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

final _template1 = $.template('<p> </p>');
final _template3 = $.template('<p> </p>');
final _template4 = $.template('<p> </p>');

void _component(Node $anchor, AppProperties $properties) {
  $.push($properties, false);

  var x = 7;

  $.init();

  // Init
  var fragment = $.comment($anchor);
  var node = $.childFragment<Comment>(fragment);

  bool node$if$condition() {
    return x > 10;
  }

  void node$if$consequent(Node $anchor) {
    // Init
    var p = $.open<Element>($anchor, true, _template1);
    var text = $.child<Text>(p);

    $.nodeValue(text, '$x is greater than 10');
    $.close($anchor, p);
  }

  void node$if$alternate(Node $anchor) {
    // Init
    var fragment1 = $.comment($anchor);
    var node1 = $.childFragment<Comment>(fragment1);

    bool node1$if$condition() {
      return 5 > x;
    }

    void node1$if$consequent(Node $anchor) {
      var p1 = $.open<Element>($anchor, true, _template3);
      var text1 = $.child<Text>(p1);

      $.nodeValue(text1, '$x is less than 5');
      $.close($anchor, p1);
    }

    void node1$if$alternate(Node $enchor) {
      var p2 = $.open<Element>($anchor, true, _template4);
      var text2 = $.child<Text>(p2);

      $.nodeValue(text2, '$x is between 5 and 10');
      $.close($anchor, p2);
    }

    $.ifBlock(
      node1,
      node1$if$condition,
      node1$if$consequent,
      node1$if$alternate,
    );

    $.closeFragment($anchor, fragment1);
  }

  $.ifBlock(
    node,
    node$if$condition,
    node$if$consequent,
    node$if$alternate,
  );

  $.closeFragment($anchor, fragment);
  $.pop();
}
