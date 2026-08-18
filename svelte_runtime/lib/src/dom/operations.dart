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
  elementPrototype.internalClickReference = null.toExternalReference;

  // the following assignments improve perf of lookups on DOM nodes.
  elementPrototype.internalAttributes = null;
  elementPrototype.internalSyles = null;
  textPrototype.internalText = null;
}

Comment createComment([String text = '']) {
  return document.createComment(text);
}

Text createText([String text = '']) {
  return document.createTextNode(text);
}

@optionalTypeArgs
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

  setHydrateNode<Node?>(next);
  return unsafeCast<T>(next);
}

void setID(Element element, String id) {
  element.id = id;
}

void setTextContent(Node node, String text) {
  node.textContent = text;
}

void clearTextContent(Node node) {
  setTextContent(node, '');
}

void setText(Text text, String value) {
  String currentValue = text.internalText ??= text.nodeValue ?? '';

  if (value != currentValue) {
    text
      ..nodeValue = value
      ..internalText = value;
  }
}

extension Assignment on JSObject {
  @JS('__attributes')
  external ExternalDartReference<Map<String, String?>?> _attributesReference;

  @internal
  Map<String, String?>? get internalAttributes {
    return _attributesReference.toDartObject;
  }

  @internal
  set internalAttributes(Map<String, String?>? attributes) {
    _attributesReference = attributes.toExternalReference;
  }

  @JS('__styles')
  external ExternalDartReference<Map<String, String?>?> _stylesReference;

  @internal
  Map<String, String?>? get internalSyles {
    return _stylesReference.toDartObject;
  }

  @internal
  set internalSyles(Map<String, String?>? styles) {
    _stylesReference = styles.toExternalReference;
  }

  @JS('__t')
  external ExternalDartReference<String?> _textReference;

  @internal
  String? get internalText {
    return _textReference.toDartObject;
  }

  @internal
  set internalText(String? t) {
    _textReference = t.toExternalReference;
  }

  @JS('__lazy')
  external ExternalDartReference<Object?> _lazyReference;

  @internal
  Object? get internalLazy {
    return _lazyReference.toDartObject;
  }

  @internal
  set internalLazy(Object? lazy) {
    _lazyReference = lazy.toExternalReference;
  }

  @JS('__click')
  @internal
  external ExternalDartReference<void Function(Event)?> internalClickReference;

  @internal
  void Function(Event)? get internalClick {
    return internalClickReference.toDartObject;
  }

  @internal
  set internalClick(void Function(Event)? lazy) {
    _lazyReference = lazy.toExternalReference;
  }
}
