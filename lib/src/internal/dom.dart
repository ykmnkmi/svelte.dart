import 'dart:html';

void append(Node target, Node node) {
  target.append(node);
}

void insert(Node target, Node node, [Node? anchor]) {
  target.insertBefore(node, anchor);
}

void remove(Node node) {
  node.remove();
}

Element element(String tag) {
  return Element.tag(tag);
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

void setData(Text node, String data) {
  if (node.wholeText != data) {
    node.data = data;
  }
}
