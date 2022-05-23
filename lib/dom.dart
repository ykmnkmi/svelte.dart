import 'dart:html' show Element, EventListener, Node, Text;

export 'dart:html' show AnchorElement, ButtonElement, Element, Event, Node, document, window;

Text empty() {
  return text('');
}

Text space() {
  return text(' ');
}

Text text(String text) {
  return Text(text);
}

T element<T extends Element>(String name) {
  return Element.tag(name) as T;
}

void attribute(Element node, String name, String? value) {
  if (value == null) {
    node.removeAttribute(name);
  } else {
    node.setAttribute(name, value);
  }
}

void data(Text node, String data) {
  if (node.wholeText != data) {
    node.data = data;
  }
}

void content(Element node, String content) {
  node.text = content;
}

void html(Element node, String? html) {
  node.innerHtml = html;
}

void Function() listen(Node node, String type, EventListener listener, [bool? useCapture]) {
  node.addEventListener(type, listener, useCapture);
  return () {
    node.removeEventListener(type, listener, useCapture);
  };
}

void insert(Node target, Node node, [Node? anchor]) {
  target.insertBefore(node, anchor);
}

void remove(Node node) {
  node.remove();
}
