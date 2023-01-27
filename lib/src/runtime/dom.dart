import 'dart:async' show FutureOr;
import 'dart:html' show Element, Event, EventListener, EventTarget, Node, Text;

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

void setData(Text text, String? data) {
  text.data = data;
}

void updateData(Text text, String? data) {
  if (text.wholeText != data) {
    text.data = data;
  }
}

void setText(Node node, String? data) {
  node.text = data;
}

String? getAttribute(Element element, String attribute) {
  return element.getAttribute(attribute);
}

void setAttribute(Element element, String attribute, Object value) {
  element.setAttribute(attribute, value);
}

void removeAttribute(Element element, String attribute) {
  element.removeAttribute(attribute);
}

void updateAttribute(Element element, String attribute, Object? value) {
  if (value == null) {
    removeAttribute(element, attribute);
  } else if (value != getAttribute(element, attribute)) {
    setAttribute(element, attribute, value);
  }
}

void insert(Node node, Node child, [Node? anchor]) {
  node.insertBefore(child, anchor);
}

void append(Node node, Node child) {
  node.append(child);
}

EventListener listener(FutureOr<void> Function() function) {
  return (Event event) {
    function();
  };
}

void listen(EventTarget target, String type, EventListener listener) {
  target.addEventListener(type, listener);
}

void cancel(EventTarget target, String type, EventListener listener) {
  target.removeEventListener(type, listener);
}

void remove(Node node) {
  node.remove();
}
