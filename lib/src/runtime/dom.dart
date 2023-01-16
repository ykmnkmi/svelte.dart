import 'dart:html';

import 'package:meta/dart2js.dart';
import 'package:svelte/src/runtime/utilities.dart';

T element<T extends Element>(String tag) {
  return unsafeCast<T>(Element.tag(tag));
}

Text empty() {
  return text('');
}

Text space() {
  return text(' ');
}

Text text(String text) {
  return Text(text);
}

@noInline
void setData(Text text, String? data) {
  text.data = data;
}

@noInline
void updateData(Text text, String? data) {
  if (text.wholeText != data) {
    text.data = data;
  }
}

@noInline
String? getAttribute(Element element, String attribute) {
  return element.getAttribute(attribute);
}

@noInline
void setAttribute(Element element, String attribute, Object value) {
  element.setAttribute(attribute, value);
}

@noInline
void removeAttribute(Element element, String attribute) {
  element.removeAttribute(attribute);
}

@noInline
void updateAttribute(Element element, String attribute, Object? value) {
  if (value == null) {
    removeAttribute(element, attribute);
  } else if (value != getAttribute(element, attribute)) {
    setAttribute(element, attribute, value);
  }
}

@noInline
void insert(Node node, Node child, [Node? anchor]) {
  node.insertBefore(child, anchor);
}

@noInline
void append(Node node, Node child) {
  node.append(child);
}

@noInline
EventListener eventListener(void Function() function) {
  return (Event event) {
    function();
  };
}

@noInline
void listen(EventTarget target, String type, EventListener listener) {
  target.addEventListener(type, listener);
}

@noInline
void cancel(EventTarget target, String type, EventListener listener) {
  target.removeEventListener(type, listener);
}

@noInline
void remove(Node node) {
  node.remove();
}
