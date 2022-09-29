import 'dart:html';

import 'package:meta/dart2js.dart';

@noInline
Element element(String tag) {
  return Element.tag(tag);
}

Text empty() {
  return text('');
}

Text space() {
  return text(' ');
}

@noInline
Text text(String text) {
  return Text(text);
}

@noInline
void setText(Text target, String? text) {
  target.data = text;
}

@noInline
void diffText(Text target, String? oldText, String? newText) {
  if (oldText != newText) {
    target.data = newText;
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
void insert(Node target, Node child, [Node? anchor]) {
  target.insertBefore(child, anchor);
}

@noInline
void append(Node node, Node child) {
  node.append(child);
}

@noInline
EventListener eventListener<T extends Event>(void Function() function) {
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
