// TODO(runtime): move to web package
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
void setData(Text target, String? data) {
  target.data = data;
}

@noInline
void setText(Node target, String? content) {
  target.text = content;
}

@noInline
void setInnerHtml(Element target, String? html) {
  // TODO(runtime): can be replaced with js_util version
  // setProperty<String>(element, 'innerHtml', html);
  target.innerHtml = html;
}

@noInline
String? getAttribute(Element target, String attribute) {
  return target.getAttribute(attribute);
}

@noInline
void setAttribute(Element target, String attribute, Object value) {
  target.setAttribute(attribute, value);
}

@noInline
void removeAttribute(Element element, String attribute) {
  element.removeAttribute(attribute);
}

@noInline
void updateAttribute(Element target, String attribute, Object? value) {
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
  target.append(child);
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
void appendStyleSheet(Node target, Element style) {
  // TODO(runtime): can be replaced with js_util version
  // append(getProperty<HeadElement?>(node, 'head') ?? node, style);
  append(target is HtmlDocument ? target.head ?? target : target, style);
}

@noInline
void appendText(Element target, String text) {
  target.appendText(text);
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
