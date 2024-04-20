import 'dart:js_interop';

import 'package:meta/dart2js.dart';
import 'package:meta/meta.dart';
import 'package:web/web.dart' hide EventListener;

typedef EventListener = void Function(Event);

@noInline
@optionalTypeArgs
T element<T extends Element>(String tag) {
  return document.createElement(tag) as T;
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
void setData(Text target, String data) {
  target.data = data;
}

@noInline
void setText(Node target, String text) {
  target.text = text;
}

@noInline
void setInnerHtml(Element target, String html) {
  target.innerHTML = html;
}

@noInline
String? getAttribute(Element target, String attribute) {
  return target.getAttribute(attribute);
}

@noInline
void setAttribute(Element target, String attribute, String value) {
  target.setAttribute(attribute, value);
}

@noInline
void removeAttribute(Element element, String attribute) {
  element.removeAttribute(attribute);
}

@noInline
void updateAttribute(Element target, String attribute, String? value) {
  if (value == null) {
    removeAttribute(target, attribute);
  } else if (getAttribute(target, attribute) != value) {
    setAttribute(target, attribute, value);
  }
}

@noInline
void insert(Element target, Node child, [Node? anchor]) {
  target.insertBefore(child, anchor);
}

@noInline
void append(Node target, Node child) {
  target.appendChild(child);
}

@noInline
void appendStyles(Node? target, String styleSheetID, String styles) {
  Node appendStylesTo = getRootForStyle(target);

  if (appendStylesTo.getElementById(styleSheetID) == null) {
    HTMLStyleElement style = element('style');
    style.id = styleSheetID;
    style.text = styles;
    appendStyleSheet(appendStylesTo, style);
  }
}

// ShadowRoot | Document target
@noInline
void appendStyleSheet(Node target, HTMLStyleElement style) {
  append(target.head ?? target, style);
}

@noInline
void appendText(Element target, String text) {
  target.append(Text(text));
}

@noInline
Node getRootForStyle(Node? node) {
  if (node == null) {
    return document;
  }

  Node root = node.getRootNode();

  if (root is ShadowRoot) {
    return root;
  }

  return node.ownerDocument as Node;
}

@noInline
EventListener listener(void Function() function) {
  void handler(Event event) {
    function();
  }

  return handler;
}

@noInline
void Function() listen(
  EventTarget target,
  String type,
  EventListener listener,
) {
  JSFunction fn = listener.toJS;
  target.addEventListener(type, fn);

  void cancel() {
    target.removeEventListener(type, fn);
  }

  return cancel;
}

@noInline
void detach(Node node) {
  node.parentNode?.removeChild(node);
}

extension on Node {
  external HTMLHeadElement? get head;

  external Element? getElementById(String id);
}
