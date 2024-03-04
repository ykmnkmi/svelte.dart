import 'dart:js_interop';

import 'package:svelte_js/internal.dart' as $; // ignore: library_prefixes
import 'package:svelte_js/svelte_js.dart';
import 'package:web/web.dart';

extension type NestedProperties._(JSObject object) implements JSObject {
  factory NestedProperties({required int answer}) {
    return NestedProperties._boxed(answer: answer.toJS);
  }

  external factory NestedProperties._boxed({JSNumber? answer});

  @JS('answer')
  external JSNumber get _answer;

  int get answer => _answer.toDartInt;
}

extension type const Nested._(Component<NestedProperties> component) {
  void call(Node node, {required int answer}) {
    component(node, NestedProperties._boxed(answer: answer.toJS));
  }
}

const Nested nested = Nested._(_component);

final _template = $.template('<p> </p>');

void _component(Node $anchor, NestedProperties $properties) {
  $.push($properties, false);
  $.init();

  /* Init */
  var p = $.open<Element>($anchor, true, _template);
  var text = $.child<Text>(p);

  $.textEffect(text, () => 'The answer is ${$properties.answer}');
  $.close($anchor, p);
  $.pop();
}
