import 'dart:html';

export 'dart:html' show Element, Node, Text, document, window;

void append(Element target, Node node) {
  target.append(node);
}

void insert(Element target, Node node, [Node? anchor]) {
  target.insertBefore(node, anchor);
}

void remove(Node node) {
  node.remove();
}

Element element(String tag) {
  return document.createElement(tag);
}

Text text(String text) {
  return Text(text);
}

Text space() {
  return text(' ');
}

Text empty() {
  return text('');
}

void Function() listen(Node target, String type, EventListener handler) {
  target.addEventListener(type, handler);
  return () {
    target.removeEventListener(type, handler);
  };
}

void attr(Element node, String attribute, String? value) {
  if (value == null) {
    node.removeAttribute(attribute);
  } else if (value != node.getAttribute(attribute)) {
    node.setAttribute(attribute, value);
  }
}

void setData(Text node, String data) {
  if (node.wholeText != data) {
    node.data = data;
  }
}

void setStyle(Element node, String name, String value, [bool important = false]) {
  if (important) {
    node.style.setProperty(name, value, 'important');
  } else {
    node.style.setProperty(name, value);
  }
}
