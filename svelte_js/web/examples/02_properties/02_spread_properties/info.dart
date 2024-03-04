import 'dart:js_interop';

import 'package:svelte_js/internal.dart' as $; // ignore: library_prefixes
import 'package:svelte_js/svelte_js.dart';
import 'package:web/web.dart';

extension type InfoProperties._(JSObject object) implements JSObject {
  factory InfoProperties(
      {required String name,
      required int version,
      required String speed,
      required String website}) {
    return InfoProperties._boxed(
        name: name.toJS,
        version: version.toJS,
        speed: speed.toJS,
        website: website.toJS);
  }

  external factory InfoProperties._boxed(
      {JSString name, JSNumber version, JSString speed, JSString website});

  @JS('name')
  external JSString get _name;

  String get name => _name.toDart;

  @JS('version')
  external JSNumber get _version;

  int get version => _version.toDartInt;

  @JS('speed')
  external JSString get _speed;

  String get speed => _speed.toDart;

  @JS('website')
  external JSString get _website;

  String get website => _website.toDart;
}

extension type const Info._(Component<InfoProperties> component) {
  void call(Node node,
      {required String name,
      required int version,
      required String speed,
      required String website}) {
    component(
        node,
        InfoProperties(
            name: name, version: version, speed: speed, website: website));
  }
}

const Info info = Info._(_component);

final _template = $.template(
    '<p>The <code> </code> <a>npm</a> and <a>learn more here</a>.</p>');

void _component(Node $anchor, InfoProperties $properties) {
  $.push($properties, false);
  $.init();

  /* Init */
  var p = $.open<Element>($anchor, true, _template);
  var code = $.sibling<Element>($.child<Text>(p));
  var text = $.space($.child<Text>(code));
  var text1 = $.sibling<Text>(code, true);
  var a = $.sibling<Element>(text1);
  var a1 = $.sibling<Element>($.sibling<Text>(a, true));
  String? ahref;
  String? a1href;

  $.renderEffect(() {
    $.text(text, $properties.name);
    $.text(text1,
        ' package is ${$properties.speed} fast. Download version ${$properties.version} from ');

    if (ahref !=
        (ahref = 'https://www.npmjs.com/package/${$properties.name}')) {
      $.attr(a, 'href', ahref);
    }

    if (a1href != (a1href = $properties.website)) {
      $.attr(a1, 'href', a1href);
    }
  });

  $.close($anchor, p);
  $.pop();
}
