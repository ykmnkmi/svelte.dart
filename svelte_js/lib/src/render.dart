@JS(r'$$')
library;

import 'dart:html';

import 'package:js/js.dart';
import 'package:meta/dart2js.dart';
import 'package:svelte_js/src/types.dart';

@JS('template')
external FragmentFactory template(String html, [bool isFragment]);

@JS('open')
external T open<T>(Node? anchor, bool useCloneNode, FragmentFactory fragment);

@JS('open_frag')
external T openFragment<T>(Node? anchor, bool useCloneNode,
    [FragmentFactory fragment]);

@JS('close')
external void close(Node? anchor, Node dom);

@JS('close_frag')
external void closeFragment(Node? anchor, Node dom);

@JS('text_effect')
external void _textEffect(Node dom, String Function() value);

@noInline
void textEffect(Node dom, String Function() value) {
  _textEffect(dom, allowInterop(value));
}

@JS('text')
external void _text(Node dom, String Function() value);

void text(Node dom, String Function() value) {
  _text(dom, allowInterop(value));
}

@JS('delegate')
external void delegate(List<String> events);

@JS('html')
external void _html(Node dom, String Function() getValue, bool svg);

@noInline
void html(Node dom, String Function() getValue, bool svg) {
  _html(dom, allowInterop(getValue), svg);
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
external Object _mount(ComponentFactory? component, _Mount options);

typedef ComponentFactory = void Function(
    Node anchor, Object properties, Object events);

@JS()
@anonymous
@staticInterop
abstract class _Mount {
  external factory _Mount({Node target});
}

@noInline
Object mount(ComponentFactory component, {required Node target}) {
  return _mount(allowInterop(component), _Mount(target: target));
}

@JS('append_styles')
external void appendStyles(Node? target, String id, String styles);
