// ignore_for_file: library_prefixes
library;

import 'dart:js_interop';

import 'package:svelte_js/internal.dart' as $;
import 'package:svelte_js/svelte_js.dart';
import 'package:web/web.dart';

extension type NestedProperties._(JSObject _) implements JSObject {
  factory NestedProperties({required int answer}) {
    return NestedProperties.js(answer: answer.toJS);
  }

  external NestedProperties.js({JSNumber? answer});

  @JS('answer')
  external JSNumber get _answer;

  int get answer => _answer.toDartInt;
}

extension type const Nested._(Component<NestedProperties> component) {
  void call(Node node, {required int answer}) {
    component(node, NestedProperties.js(answer: answer.toJS));
  }
}

const Nested nested = Nested._(_component);

final _template = $.template('<p> </p>');

void _component(Node $anchor, NestedProperties $properties) {
  $.push($properties, false);
  $.init();

  // Init
  var p = $.open<Element>($anchor, true, _template);
  var text = $.child<Text>(p);

  // Update
  String text$textEffect() {
    return 'The answer is ${$properties.answer}';
  }

  $.textEffect(text, text$textEffect);
  $.close($anchor, p);
  $.pop();
}
