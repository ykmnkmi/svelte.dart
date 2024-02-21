@JS(r'$$')
library;

import 'dart:js_interop';

import 'package:meta/dart2js.dart';
import 'package:svelte_js/src/types.dart';
import 'package:web/web.dart';

@JS('template')
external JSFunction _template(String html, [bool isFragment]);

FragmentFactory fragment(String html) {
  return FragmentFactory(_template(html, true));
}

FragmentFactory template(String html) {
  return FragmentFactory(_template(html));
}

@JS('open')
external T open<T extends JSAny?>(
    Node? anchor, bool useCloneNode, FragmentFactory fragment);

@JS('open_frag')
external T openFragment<T extends JSAny?>(Node? anchor, bool useCloneNode,
    [FragmentFactory fragment]);

@JS('close')
external void close(Node? anchor, Node dom);

@JS('close_frag')
external void closeFragment(Node? anchor, Node dom);

@JS('event')
external void _event<T extends Event>(
    String eventName, Node node, JSFunction handler, bool capture,
    [bool passive]);

void event<T extends Event>(
    String eventName, Node node, void Function(T) handler, bool capture) {
  _event(eventName, node, handler.toJS, capture);
}

void eventPassive<T extends Event>(
    String eventName, Node node, void Function(T) handler, bool capture) {
  _event(eventName, node, handler.toJS, capture, true);
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
external void _html(Node dom, JSFunction getValue, bool svg);

@noInline
void html(Node dom, String Function() getValue, bool svg) {
  _html(dom, getValue.toJS, svg);
}

@JS('attr')
external void attr(Element dom, String attribute, String? value);

String stringify(Object? value) {
  if (value == null) {
    return '';
  }

  return value is String ? value : '$value';
}

@JS('mount')
external JSObject _mount(JSFunction? component, _Mount options);

typedef ComponentFactory = void Function(Node anchor, JSObject properties);

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
