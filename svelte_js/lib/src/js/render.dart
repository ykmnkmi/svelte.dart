@JS(r'$$')
library;

import 'dart:js_interop';

import 'package:meta/dart2js.dart';
import 'package:svelte_js/src/js/unsafe_cast.dart';
import 'package:svelte_js/src/types.dart';
import 'package:web/web.dart';

@JS('template')
external JSFunction _template(JSString html, [JSBoolean returnFragment]);

Template template(String html) {
  return Template(_template(html.toJS));
}

Fragment fragment(String html) {
  return Fragment(_template(html.toJS, true.toJS));
}

@JS('open')
external JSAny _open(Node? anchor, JSBoolean useCloneNode, JSFunction template);

T open<T extends JSAny>(Node? anchor, bool useCloneNode, Template template) {
  return _open(anchor, useCloneNode.toJS, template) as T;
}

@JS('open_frag')
external DocumentFragment _openFragment(
  Node? anchor,
  JSBoolean useCloneNode, [
  JSFunction fragment,
]);

DocumentFragment openFragment(
  Node? anchor,
  bool useCloneNode,
  Fragment fragment,
) {
  return _openFragment(anchor, useCloneNode.toJS, fragment);
}

@JS('space')
external Node space(Node anchor);

@JS('comment')
external DocumentFragment comment(Node? anchor);

@JS('close')
external void close(Node? anchor, Node dom);

@JS('close_frag')
external void closeFragment(Node? anchor, DocumentFragment fragment);

@JS('event')
external void _event<T extends Event>(
  JSString eventName,
  Element dom,
  JSFunction handler,
  JSBoolean capture, [
  JSBoolean passive,
]);

void event<T extends Event>(
  String eventName,
  Element dom,
  void Function(T event) handler,
  bool capture, [
  bool? passive,
]) {
  if (passive == null) {
    _event(eventName.toJS, dom, handler.toJS, capture.toJS);
  } else {
    _event(eventName.toJS, dom, handler.toJS, capture.toJS, passive.toJS);
  }
}

@JS('text_effect')
external void _textEffect(Node dom, JSFunction value);

@noInline
void textEffect(Node dom, String Function() value) {
  _textEffect(dom, value.toJS);
}

@JS('text')
external void _text(Node dom, JSString value);

void text(Node dom, String value) {
  _text(dom, value.toJS);
}

@JS('html')
external void _html(Node dom, JSFunction value, JSBoolean svg);

@noInline
void html(Node dom, String Function() value, bool svg) {
  _html(dom, value.toJS, svg.toJS);
}

@JS('attr_effect')
external void _attrEffect(Element dom, JSString attribute, JSFunction value);

void attrEffect(Element dom, String attribute, String Function() value) {
  _attrEffect(dom, attribute.toJS, value.toJS);
}

@JS('attr')
external void _attr(Element dom, JSString attribute, JSString? value);

void attr(Element dom, String attribute, String? value) {
  _attr(dom, attribute.toJS, value?.toJS);
}

@JS('spread_props')
external JSObject _spreadProperties(JSObject object, [JSObject rest]);

T spreadProperties<T extends JSObject>(T object, [JSObject? rest]) {
  if (rest == null) {
    return _spreadProperties(object) as T;
  }

  return _spreadProperties(object, rest) as T;
}

extension type _Mount._(JSObject ref) implements JSObject {
  external factory _Mount({Node target});

  external Node target;
}

@JS('mount')
external JSObject _mount(JSFunction component, _Mount options);

ComponentReference mount<T extends JSObject>(
  Component<T> component, {
  required Node target,
}) {
  return ComponentReference(_mount(component.toJS, _Mount(target: target)));
}

@JS('unmount')
external void _unmount(JSObject component);

void unmount(ComponentReference component) {
  _unmount(component);
}

@JS('append_styles')
external void _appendStyles(Node? target, JSString id, JSString styles);

void appendStyles(Node? target, String id, String styles) {
  _appendStyles(target, id.toJS, styles.toJS);
}

@JS('prop')
external JSFunction _prop(JSObject properties, JSString key, JSNumber flag);

T Function([T? value]) prop<T>(JSObject properties, String key, int flag) {
  var jsFunction = _prop(properties, key.toJS, flag.toJS);

  return ([T? value]) {
    var jsValue = unsafeCast<JSAny?>(value);
    var result = jsFunction.callAsFunction(null, jsValue);
    return unsafeCast<T>(result);
  };
}

@JS('init')
external void _init();

void init() {
  _init();
}
