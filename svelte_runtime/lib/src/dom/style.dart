part of '../dom.dart';

@noInline
void appendStyles(Node? target, String styleSheetID, String styles) {
  Node appendStylesTo = getRootForStyle(target);

  if (appendStylesTo.getElementById(styleSheetID) == null) {
    HTMLStyleElement style = element('style');
    style.id = styleSheetID;
    style.textContent = styles;
    appendStyleSheet(appendStylesTo, style);
  }
}

@noInline
Node getRootForStyle(Node? node) {
  if (node == null) {
    return document;
  }

  Node root = node.getRootNode();

  if (root.isA<ShadowRoot>()) {
    return root;
  }

  return node.ownerDocument as Node;
}

@noInline
void appendStyleSheet(
    /* ShadowRoot|Document */ Node target, HTMLStyleElement style) {
  append(target.head ?? target, style);
}

void setStyle(Node node, String key, String? value, [bool important = false]) {
  if (value == null) {
    (node as HTMLElement).style.removeProperty(key);
  } else {
    (node as HTMLElement)
        .style
        .setProperty(key, value, important ? 'important' : '');
  }
}
