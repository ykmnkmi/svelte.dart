import 'dart:async';
import 'dart:html';
import 'dart:js_util';

import 'package:meta/dart2js.dart';

@noInline
T element<T extends Element>(String tag) {
  return document.createElement(tag) as T;
}

@noInline
Text empty() {
  return text('');
}

@noInline
Text space() {
  return text(' ');
}

@noInline
Text text(String text) {
  return Text(text);
}

@noInline
void setData(Text text, String data) {
  text.data = data;
}

@noInline
void setText(Node node, String? content) {
  node.text = content;
}

@noInline
void setInnerHtml(Element element, String html) {
  element.innerHtml = html;
}

@noInline
String? getAttribute(Element element, String attribute) {
  return element.getAttribute(attribute);
}

@noInline
void setAttribute(Element element, String attribute, String value) {
  element.setAttribute(attribute, value);
}

@noInline
void removeAttribute(Element element, String attribute) {
  element.removeAttribute(attribute);
}

@noInline
void updateAttribute(Element element, String attribute, String? value) {
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
void appendStyles(Node target, String styleSheetId, String styles) {
  var appendStylesTo = getRootForStyle(target);
  var args = <Object?>[styleSheetId];

  if (callMethod<bool>(appendStylesTo, 'getElementById', args)) {
    var style = element<StyleElement>('style');
    style.id = styleSheetId;
    style.text = styles;
    appendStyleSheet(appendStylesTo, style);
  }
}

@noInline
void appendStyleSheet(Node node, StyleElement style) {
  if (node is HtmlDocument) {
    append(node.head ?? node, style);
  } else {
    append(node, style);
  }
}

@noInline
Node getRootForStyle(Node node) {
  var root = node.getRootNode();

  if (root is ShadowRoot && root.host != null) {
    return root;
  }

  return node.ownerDocument as Document;
}

@noInline
EventListener listener(FutureOr<void> Function() function) {
  return (Event event) {
    function();
  };
}

@noInline
void Function() listen(
  EventTarget target,
  String type,
  EventListener? listener,
) {
  target.addEventListener(type, listener);

  return () {
    target.removeEventListener(type, listener);
  };
}

@noInline
void remove(Node node) {
  node.remove();
}
