import 'dart:js_interop';

import 'package:meta/dart2js.dart';
import 'package:meta/meta.dart';
import 'package:web/web.dart' hide EventListener;

part 'dom/attribute.dart';
part 'dom/event.dart';
part 'dom/hydration.dart';
part 'dom/style.dart';

@noInline
void append(Node target, Node child) {
  target.appendChild(child);
}

@noInline
void insert(Element target, Node child, [Node? anchor]) {
  target.insertBefore(child, anchor);
}

@noInline
void remove(Node node) {
  node.parentNode?.removeChild(node);
}

@noInline
@optionalTypeArgs
T element<T extends Element>(String tag) {
  return document.createElement(tag) as T;
}

@noInline
Text text(String text) {
  return document.createTextNode(text);
}

Text space() {
  return text(' ');
}

Text empty() {
  return text('');
}

@noInline
Comment comment(String content) {
  return document.createComment(content);
}

@noInline
void setInnerHtml(Element target, String html) {
  target.innerHTML = html.toJS;
}

@noInline
void setText(Node target, String text) {
  target.textContent = text;
}

@noInline
void setData(Text target, String data) {
  target.data = data;
}

List<Node> children(Element element) {
  JSArray<Node> childNodes = element.childNodes as JSArray<Node>;
  return childNodes.toDart;
}

// @noInline
// String? getAttribute(Element target, String attribute) {
//   return target.getAttribute(attribute);
// }

// @noInline
// void removeAttribute(Element element, String attribute) {
//   element.removeAttribute(attribute);
// }

// @noInline
// void updateAttribute(Element target, String attribute, String? value) {
//   if (value == null) {
//     removeAttribute(target, attribute);
//   } else if (getAttribute(target, attribute) != value) {
//     setAttribute(target, attribute, value);
//   }
// }

// @noInline
// void appendText(Element target, String text) {
//   target.append(Text(text));
// }

extension on Node {
  external HTMLHeadElement? get head;

  external Element? getElementById(String id);
}
