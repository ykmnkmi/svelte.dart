// ignore_for_file: library_prefixes
library;

import 'dart:js_interop';

import 'package:svelte_js/internal.dart' as $;
import 'package:svelte_js/svelte_js.dart';
import 'package:web/web.dart';

extension type NestedProperties._(JSObject _) implements JSObject {
  factory NestedProperties({required Object answer}) {
    return NestedProperties.js(answer: answer.toJSBox);
  }

  external NestedProperties.js({JSBoxedDartObject answer});

  @JS('answer')
  external JSBoxedDartObject get _answer;

  Object get answer => _answer.toDart;
}

extension type const Nested._(Component<NestedProperties> component) {
  void call(Node node, {Object answer = 'a mystery'}) {
    component(node, NestedProperties(answer: answer));
  }
}

const Nested nested = Nested._(_component);

final _template = $.template('<p> </p>');

void _component(Node $anchor, NestedProperties $properties) {
  $.push($properties, false);

  var answer = $.prop<Object>($properties, 'answer', 0);

  $.init();

  // Init
  var p = $.open<Element>($anchor, true, _template);
  var text = $.child<Text>(p);

  // Update
  String text$effect() {
    return 'The answer is ${answer()}';
  }

  $.textEffect(text, text$effect);
  $.close($anchor, p);
  $.pop();
}
