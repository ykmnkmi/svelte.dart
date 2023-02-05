// TODO(runtime): move to js package
library;

import 'dart:async';
import 'dart:html';

import 'package:meta/dart2js.dart';

@noInline
Element element(String tag) {
  return document.createElement(tag);
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
void setData(Text text, String data) {
  text.data = data;
}

@noInline
void setText(Node node, String? content) {
  node.text = content;
}

@noInline
void setInnerHtml(Element element, String? html) {
  // TODO(runtime): can be replaced with js_util version
  // setProperty<String>(element, 'innerHtml', html);
  element.innerHtml = html;
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
  } else if (getAttribute(element, attribute) != value) {
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
void appendStyles(Node? target, String styleSheetId, String styles) {
  var appendStylesTo = getRootForStyle(target);
  var appendStylesToNode = appendStylesTo as NonElementParentNode;

  if (appendStylesToNode.getElementById(styleSheetId) == null) {
    var style = element('style');
    style.id = styleSheetId;
    style.text = styles;
    appendStyleSheet(appendStylesTo, style);
  }
}

@noInline
void appendStyleSheet(Node node, Element style) {
  // TODO(runtime): can be replaced with js_util version
  // append(getProperty<HeadElement?>(node, 'head') ?? node, style);
  append(node is HtmlDocument ? node.head ?? node : node, style);
}

@noInline
Node getRootForStyle(Node? node) {
  if (node == null) {
    return document;
  }

  var root = node.getRootNode();

  // TODO(runtime): can be replaced with js_util version
  // if (getProperty<Node?>(root, 'host') != null) {
  if (root is ShadowRoot && root.host != null) {
    return root;
  }

  return node.ownerDocument as Node;
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
