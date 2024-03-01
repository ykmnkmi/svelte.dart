@JS(r'$$')
library;

import 'dart:js_interop';

import 'package:meta/dart2js.dart';
import 'package:meta/meta.dart';
import 'package:svelte_js/src/types.dart';
import 'package:web/web.dart';

@JS('template')
external JSFunction _template(JSString html, [JSBoolean returnFragment]);

TemplateFactory template(String html) {
  return TemplateFactory(_template(html.toJS));
}

FragmentFactory fragment(String html) {
  return FragmentFactory(_template(html.toJS, true.toJS));
}

@JS('open')
external JSAny _open(Node? anchor, JSBoolean useCloneNode,
    [JSFunction templateFactory]);

T open<T extends JSAny>(
    Node? anchor, bool useCloneNode, TemplateFactory templateFactory) {
  return _open(anchor, useCloneNode.toJS, templateFactory) as T;
}

@JS('open_frag')
external DocumentFragment _openFragment(Node? anchor, JSBoolean useCloneNode,
    [JSFunction fragmentFactory]);

DocumentFragment openFragment(
    Node? anchor, bool useCloneNode, FragmentFactory fragmentFactory) {
  return _openFragment(anchor, useCloneNode.toJS, fragmentFactory);
}

@JS('comment')
external DocumentFragment _comment(Node? anchor);

DocumentFragment comment(Node? anchor) {
  return _comment(anchor);
}

@JS('close')
external void _close(Node? anchor, Node dom);

void close(Node? anchor, Node dom) {
  _close(anchor, dom);
}

@JS('close_frag')
external void _closeFragment(Node? anchor, DocumentFragment fragment);

void closeFragment(Node? anchor, DocumentFragment fragment) {
  _closeFragment(anchor, fragment);
}

@JS('event')
external void _event<T extends Event>(
    JSString eventName, Element dom, JSFunction handler, JSBoolean capture,
    [JSBoolean passive]);

void event<T extends Event>(
    String eventName, Element dom, void Function(T) handler, bool capture,
    [bool? passive]) {
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

@JS('attr')
external void _attr(Element dom, JSString attribute, [JSString value]);

void attr(Element dom, String attribute, [String? value]) {
  if (value == null) {
    _attr(dom, attribute.toJS);
  } else {
    _attr(dom, attribute.toJS, value.toJS);
  }
}

extension type _Mount._(JSObject ref) implements JSObject {
  external factory _Mount({Node target});

  external Node target;
}

@JS('mount')
external JSObject _mount(JSFunction component, _Mount options);

@optionalTypeArgs
typedef Component<T extends JSObject> = void Function(
    Node anchor, T properties);

extension type ComponentReference._(JSObject component) implements JSObject {}

ComponentReference mount<T extends JSObject>(Component<T> component,
    {required Node target}) {
  return ComponentReference._(_mount(component.toJS, _Mount(target: target)));
}

@JS('append_styles')
external void _appendStyles(Node? target, JSString id, JSString styles);

void appendStyles(Node? target, String id, String styles) {
  _appendStyles(target, id.toJS, styles.toJS);
}

@JS('unmount')
external void _unmount(JSObject component);

void unmount(ComponentReference component) {
  _unmount(component);
}