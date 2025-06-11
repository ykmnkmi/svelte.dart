import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:meta/meta.dart';
import 'package:svelte_runtime/src/dom/hydration.dart';
import 'package:svelte_runtime/src/unsafe_cast.dart';
import 'package:web/web.dart';

@JS('Node.prototype')
external JSObject nodePrototype;

@JS('Text.prototype')
external JSObject textPrototype;

@JS('Element.prototype')
external JSObject elementPrototype;

/// Initialize these lazily to avoid issues when using the runtime in a server
/// context where these globals are not available while avoiding a separate
/// server entry point.
void init() {
  elementPrototype.clickReference = null.toExternalReference;

  // the following assignments improve perf of lookups on DOM nodes.
  elementPrototype.attributes__ = null;
  elementPrototype.styles__ = null;
  textPrototype.t__ = null;
}

Comment createComment([String text = '']) {
  return document.createComment(text);
}

Text createText([String text = '']) {
  return document.createTextNode(text);
}

T createElement<T extends Element>(String tag) {
  return unsafeCast<T>(document.createElement(tag));
}

@optionalTypeArgs
T importNode<T extends Node>(Node node) {
  return unsafeCast<T>(document.importNode(node, true));
}

@optionalTypeArgs
T cloneNode<T extends Node>(Node node) {
  return unsafeCast<T>(node.cloneNode(true));
}

void before(Node anchor, Node node) {
  unsafeCast<Element>(anchor).before(node);
}

void after(Node anchor, Node node) {
  unsafeCast<Element>(anchor).after(node);
}

@optionalTypeArgs
T appendChild<T extends Node>(Node target, Node child) {
  return unsafeCast<T>(target.appendChild(child));
}

void appendNode(Node target, Node node) {
  unsafeCast<Element>(target).append(node);
}

void appendNodes(Node target, Node node, Node other) {
  target.callMethod('append'.toJS, node, other);
}

void remove(Node node) {
  unsafeCast<Element>(node).remove();
}

@optionalTypeArgs
T getFirstChild<T extends Node?>(Node node) {
  return unsafeCast<T>(node.firstChild);
}

@optionalTypeArgs
T getLastChild<T extends Node?>(Node node) {
  return unsafeCast<T>(node.lastChild);
}

@optionalTypeArgs
T getPreviousSibling<T extends Node?>(Node node) {
  return unsafeCast<T>(node.previousSibling);
}

@optionalTypeArgs
T getNextSibling<T extends Node?>(Node node) {
  return unsafeCast<T>(node.nextSibling);
}

@optionalTypeArgs
T child<T extends Node?>(Node node, [bool isText = false]) {
  if (!hydrating) {
    return getFirstChild<T>(node);
  }

  Node? child = getFirstChild<Node?>(unsafeCast<Node>(hydrateNode));

  // Child can be null if we have an element with a single child, like
  // `<p>{text}</p>`, where `text` is empty.
  if (child == null) {
    child = appendChild<Node>(unsafeCast<Node>(hydrateNode), createText());
  } else if (isText && child.nodeType != 3) {
    Text text = createText();
    before(child, node);
    setHydrateNode<Node>(text);
    return unsafeCast<T>(text);
  }

  setHydrateNode<Node>(child);
  return unsafeCast<T>(child);
}

@optionalTypeArgs
T firstChild<T extends Node?>(Node fragment, [bool isText = false]) {
  if (!hydrating) {
    // When not hydrating, `fragment` is a `DocumentFragment` (the result of
    // calling `openFragment`).
    Comment child = getFirstChild<Comment>(fragment);

    // TODO(operations): prevent user comments with the empty string when
    //  `preserveComments` is true.
    if (child.nodeType == 8 && child.data == '') {
      return getNextSibling<T>(child);
    }

    return unsafeCast<T>(child);
  }

  // If an {expression} is empty during SSR, there might be no text node to
  // hydrate — we must therefore create one.
  if (isText && hydrateNode?.nodeType != 3) {
    Text text = createText();

    if (hydrateNode != null) {
      before(unsafeCast<Node>(hydrateNode), text);
    }

    setHydrateNode<Node>(text);
    return unsafeCast<T>(text);
  }

  return unsafeCast<T>(hydrateNode);
}

@optionalTypeArgs
T sibling<T extends Node>(Node? node, [int count = 1, bool isText = false]) {
  Node? next = hydrating ? hydrateNode : node, last;

  while (count-- > 0) {
    last = next;
    next = getNextSibling<Node?>(unsafeCast<Node>(next));
  }

  if (!hydrating) {
    return unsafeCast<T>(next);
  }

  int? type = next?.nodeType;

  // If a sibling {expression} is empty during SSR, there might be no text node
  // to hydrate — we must therefore create one.
  if (isText && type != 3) {
    Text text = createText();

    // If the next sibling is `null` and we're handling text then it's because
    // the SSR content was empty for the text, so we need to generate a new text
    // node and insert it after the last sibling.
    if (next != null) {
      before(next, text);
    } else if (last != null) {
      after(last, text);
    }

    setHydrateNode<Node>(text);
    return unsafeCast<T>(text);
  }

  setHydrateNode<Node>(next);
  return unsafeCast<T>(next);
}

void setID(Element element, String id) {
  element.id = id;
}

void setTextContent(Node node, String text) {
  node.textContent = text;
}

void clearTextContent(Node node) {
  node.textContent = '';
}

extension Assignment on JSObject {
  @JS('__attributes')
  external ExternalDartReference<Map<String, String?>?> attributesReference;

  // ignore: non_constant_identifier_names
  Map<String, String?>? get attributes__ {
    return attributesReference.toDartObject;
  }

  // ignore: non_constant_identifier_names
  set attributes__(Map<String, String?>? attributes) {
    attributesReference = attributes.toExternalReference;
  }

  @JS('__styles')
  external ExternalDartReference<Map<String, String?>?> stylesReference;

  // ignore: non_constant_identifier_names
  Map<String, String?>? get styles__ {
    return stylesReference.toDartObject;
  }

  // ignore: non_constant_identifier_names
  set styles__(Map<String, String?>? styles) {
    stylesReference = styles.toExternalReference;
  }

  @JS('__t')
  external ExternalDartReference<String?> tReference;

  // ignore: non_constant_identifier_names
  String? get t__ {
    return tReference.toDartObject;
  }

  // ignore: non_constant_identifier_names
  set t__(String? t) {
    tReference = t.toExternalReference;
  }

  @JS('__lazy')
  external ExternalDartReference<Object?> lazyReference;

  // ignore: non_constant_identifier_names
  Object? get lazy__ {
    return lazyReference.toDartObject;
  }

  // ignore: non_constant_identifier_names
  set lazy__(Object? lazy) {
    lazyReference = lazy.toExternalReference;
  }

  @JS('__click')
  external ExternalDartReference<void Function(Event)?> clickReference;
}
