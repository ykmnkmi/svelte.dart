import 'dart:js_interop';

import 'package:svelte_js/internal.dart' as $; // ignore: library_prefixes
import 'package:svelte_js/svelte_js.dart';
import 'package:web/web.dart';

extension type ThingProperties._(JSObject _) implements JSObject {
  factory ThingProperties({required String current}) {
    return ThingProperties.js(current: current.toJS);
  }

  external ThingProperties.js({JSString? current});

  @JS('current')
  external JSString get _current;

  String get current => _current.toDart;
}

extension type const Thing._(Component<ThingProperties> component) {
  void call(Node node, {required String current}) {
    component(node, ThingProperties(current: current));
  }
}

const Thing thing = Thing._(_component);

final _template = $.template(
    '<p><span class="svelte-dgndg6">initial</span> <span class="svelte-dgndg6">current</span></p>');

void _component(Node $anchor, ThingProperties $properties) {
  $.push($properties, false);

  var initial = $properties.current;

  $.init();

  // Init
  var p = $.open<Element>($anchor, true, _template);
  var span = $.child<Element>(p);
  $.attr(span, 'style', 'background-color: $initial');

  var span1 = $.sibling<Element>($.sibling<Text>(p, true));
  $.attr(span1, 'style', 'background-color: ${$properties.current}');

  // Update
  $.attrEffect(span1, 'style', () => 'The current is ${$properties.current}');
  $.close($anchor, p);
  $.pop();
}
