@JS(r'$$')
library;

import 'dart:js_interop';

import 'package:meta/dart2js.dart';
import 'package:svelte_js/src/types.dart';
import 'package:web/web.dart';

@JS('template')
external TemplateFactory template(String html, [bool returnFragment]);

@JS('open')
external T open<T extends JSAny>(Node? anchor, bool useCloneNode,
    [TemplateFactory templateFactory]);

@JS('open_frag')
external T openFragment<T extends JSAny>(Node? anchor, bool useCloneNode,
    [TemplateFactory templateFactory]);

@JS('close')
external void close(Node? anchor, Node dom);

@JS('close_frag')
external void closeFragment(Node? anchor, Node dom);

@JS('event')
external void _event<T extends Event>(
    String eventName, Element dom, JSFunction handler, bool capture,
    [bool passive]);

void event<T extends Event>(
    String eventName, Element dom, void Function(T) handler, bool capture,
    [bool? passive]) {
  if (passive == null) {
    _event(eventName, dom, handler.toJS, capture);
  } else {
    _event(eventName, dom, handler.toJS, capture, passive);
  }
}

@JS('text_effect')
external void _textEffect(Node dom, JSFunction value);

@noInline
void textEffect(Node dom, String Function() value) {
  _textEffect(dom, value.toJS);
}

@JS('text')
external void _text(Node dom, JSFunction value);

void text(Node dom, String Function() value) {
  _text(dom, value.toJS);
}

@JS('html')
external void _html(Node dom, JSFunction value, bool svg);

@noInline
void html(Node dom, String Function() value, bool svg) {
  _html(dom, value.toJS, svg);
}

@JS('attr')
external void attr(Element dom, String attribute, String? value);

@JS('mount')
external JSObject _mount(JSFunction? component, _Mount options);

@JS()
@anonymous
@staticInterop
abstract class _Mount {
  external factory _Mount({Node target});
}

@noInline
Object mount(ComponentFactory component, {required Node target}) {
  return _mount(component.toJS, _Mount(target: target));
}

@JS('append_styles')
external void appendStyles(Node? target, String id, String styles);
