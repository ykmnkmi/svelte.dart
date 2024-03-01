import 'dart:js_interop';

import 'package:svelte_js/internal.dart' as $; // ignore: library_prefixes
import 'package:svelte_js/svelte_js.dart';
import 'package:web/web.dart';

extension type NestedProperties._(JSObject object) implements JSObject {
  external factory NestedProperties._boxed({JSBoxedDartObject? answer});

  @JS('answer')
  external JSBoxedDartObject get _answer;

  Object get answer => _answer.toDart;
}

extension type const Nested._(Component<NestedProperties> component) {
  void call(Node node, {Object? answer = 'a mystery'}) {
    component(node, NestedProperties._boxed(answer: answer?.toJSBox));
  }
}

const Nested nested = Nested._(_component);

final _template = $.template('<p> </p>');

void _component(Node $anchor, NestedProperties $properties) {
  $.push($properties, false);

  var answer = $.prop<Object?>($properties, 'answer', 0);

  $.init();

  /* Init */
  var p = $.open<Element>($anchor, true, _template);
  var text = $.child<Text>(p);

  $.textEffect(text, () => 'The answer is ${answer()}');
  $.close($anchor, p);
  $.pop();
}
