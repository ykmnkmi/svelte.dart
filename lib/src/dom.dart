part of '../piko.dart';

void append(Element target, Node node) {
  target.append(node);
}

void insert(Element target, Node node, [Node? anchor]) {
  target.insertBefore(node, anchor);
}

void remove(Node node) {
  node.remove();
}

@noInline
Element element(String tag) {
  return document.createElement(tag);
}

@noInline
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
  } else if (node.getAttribute(attribute) != value) {
    node.setAttribute(attribute, value);
  }
}

@noInline
void setData(Text node, String data) {
  if (node.wholeText != data) {
    node.data = data;
  }
}
