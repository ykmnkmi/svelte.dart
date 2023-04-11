import 'dart:async';

import 'package:js/js_util.dart';
import 'package:meta/dart2js.dart';
import 'package:web/web.dart';

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
void setText(Node target, String? content) {
  target.textContent = content;
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
void appendStyles(Node? target, String styleSheetId, String styles) {
  var appendStylesTo = getRootForStyle(target);
  var appendStylesToNode = appendStylesTo as NonElementParentNode;

  if (appendStylesToNode.getElementById(styleSheetId) == null) {
    var style = element('style');
    style.id = styleSheetId;
    style.textContent = styles;
    appendStyleSheet(appendStylesTo, style);
  }
}

@noInline
void appendStyleSheet(Node target, Element style) {
  append(target is Document ? target.head ?? target : target, style);
}

@noInline
void appendText(Element target, String text) {
  target.append(text);
}

@noInline
Node getRootForStyle(Node? node) {
  if (node == null) {
    return document;
  }

  var root = node.getRootNode();

  if (root is ShadowRoot) {
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
  EventListener listener,
) {
  var fn = allowInterop(listener);
  target.addEventListener(type, fn);

  return () {
    target.removeEventListener(type, fn);
  };
}

@noInline
void detach(Node node) {
  unsafeCast<Node>(node.parentNode).removeChild(node);
}

@tryInline
@pragma('dart2js:as:trust')
T unsafeCast<T>(Object? value) {
  return value as T;
}
