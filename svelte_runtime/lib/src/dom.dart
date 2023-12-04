import 'dart:async';
import 'dart:html';

import 'package:js/js_util.dart';
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
void setData(Text target, String data) {
  target.data = data;
}

@noInline
void setText(Node target, String? text) {
  target.text = text;
}

@noInline
void setInnerHtml(Element target, String html) {
  setProperty(target, 'innerHTML', html);
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
  target.append(child);
}

@noInline
void appendStyles(Node? target, String styleSheetId, String styles) {
  Node appendStylesTo = getRootForStyle(target);
  NonElementParentNode appendStylesToNode =
      appendStylesTo as NonElementParentNode;

  if (appendStylesToNode.getElementById(styleSheetId) == null) {
    Element style = element('style');
    style.id = styleSheetId;
    style.text = styles;
    appendStyleSheet(appendStylesTo, style);
  }
}

@noInline
void appendStyleSheet(Node target, Element style) {
  if (target is HtmlDocument) {
    append(target.head ?? target, style);
  } else {
    append(target, style);
  }
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

  Node root = node.getRootNode();

  if (root is ShadowRoot) {
    return root;
  }

  return node.ownerDocument as Node;
}

@noInline
EventListener listener(FutureOr<void> Function() function) {
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
  EventListener fn = allowInterop<EventListener>(listener);
  target.addEventListener(type, fn);

  void cancel() {
    target.removeEventListener(type, fn);
  }

  return cancel;
}

@noInline
void detach(Node node) {
  node.remove();
}
