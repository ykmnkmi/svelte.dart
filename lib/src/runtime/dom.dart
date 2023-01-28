import 'dart:async';
import 'dart:html' hide DocumentOrShadowRoot;

import 'package:js/js.dart' show JS, staticInterop;
import 'package:meta/dart2js.dart' show noInline;
import 'package:svelte/src/runtime/utilities.dart';

@noInline
T element<T extends Element>(String tag) {
  return unsafeCast(Element.tag(tag));
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
void updateData(Text text, String data) {
  if (text.wholeText != data) {
    text.data = data;
  }
}

@noInline
void setText(Node node, String? text) {
  node.text = text;
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

  if (appendStylesTo.getElementById(styleSheetId) == null) {
    var style = element<StyleElement>('style');
    style.id = styleSheetId;
    style.text = styles;
    appendStyleSheet(unsafeCast(appendStylesTo), style);
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
DocumentOrShadowRoot getRootForStyle(Node node) {
  var root = node.getRootNode();

  if (root is ShadowRoot && root.host != null) {
    return unsafeCast(root);
  }

  return unsafeCast(node.ownerDocument);
}

@noInline
EventListener listener(FutureOr<void> Function() function) {
  return (Event event) {
    function();
  };
}

@noInline
void listen(EventTarget target, String type, EventListener listener) {
  target.addEventListener(type, listener);
}

@noInline
void cancel(EventTarget target, String type, EventListener listener) {
  target.removeEventListener(type, listener);
}

@noInline
void remove(Node node) {
  node.remove();
}

@JS()
@staticInterop
abstract class DocumentOrShadowRoot {}

extension on DocumentOrShadowRoot {
  external Element? getElementById(String elementId);
}
