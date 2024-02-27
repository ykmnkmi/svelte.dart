@JS(r'$$')
library;

import 'dart:js_interop';

import 'package:meta/dart2js.dart';
import 'package:svelte_js/src/types.dart';
import 'package:web/web.dart';

@JS('template')
external TemplateFactory _template(String html, [JSBoolean returnFragment]);

TemplateFactory template(String html, [bool? returnFragment]) {
  if (returnFragment == null) {
    return _template(html);
  }

  return _template(html, returnFragment.toJS);
}

@JS('open')
external JSAny _open(Node? anchor, JSBoolean useCloneNode,
    [TemplateFactory templateFactory]);

T open<T extends JSAny>(Node? anchor, bool useCloneNode,
    [TemplateFactory? templateFactory]) {
  if (templateFactory == null) {
    return _open(anchor, useCloneNode.toJS) as T;
  }

  return _open(anchor, useCloneNode.toJS, templateFactory) as T;
}

@JS('open_frag')
external JSAny _openFragment(Node? anchor, JSBoolean useCloneNode,
    [TemplateFactory templateFactory]);

T openFragment<T extends JSAny>(Node? anchor, bool useCloneNode,
    [TemplateFactory? templateFactory]) {
  if (templateFactory == null) {
    return _openFragment(anchor, useCloneNode.toJS) as T;
  }

  return _openFragment(anchor, useCloneNode.toJS, templateFactory) as T;
}

@JS('close')
external void _close(Node? anchor, Node dom);

void close(Node? anchor, Node dom) {
  _close(anchor, dom);
}

@JS('close_frag')
external void _closeFragment(Node? anchor, Node dom);

void closeFragment(Node? anchor, Node dom) {
  _closeFragment(anchor, dom);
}

@JS('event')
external void _event<T extends Event>(
    String eventName, Element dom, JSFunction handler, JSBoolean capture,
    [JSBoolean passive]);

void event<T extends Event>(
    String eventName, Element dom, void Function(T) handler, bool capture,
    [bool? passive]) {
  if (passive == null) {
    _event(eventName, dom, handler.toJS, capture.toJS);
  } else {
    _event(eventName, dom, handler.toJS, capture.toJS, passive.toJS);
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
external void _html(Node dom, JSFunction value, bool svg);

@noInline
void html(Node dom, String Function() value, bool svg) {
  _html(dom, value.toJS, svg);
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
external void _mount(JSFunction component, _Mount options);

@noInline
void mount(ComponentFactory component, {required Node target}) {
  _mount(component.toJS, _Mount(target: target));
}

@JS('append_styles')
external void _appendStyles(Node? target, JSString id, JSString styles);

void appendStyles(Node? target, String id, String styles) {
  _appendStyles(target, id.toJS, styles.toJS);
}
