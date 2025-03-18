library;

import 'package:meta/dart2js.dart';
import 'package:meta/meta.dart';
import 'package:svelte_runtime/src/dom/hydration.dart';
import 'package:svelte_runtime/src/dom/operations.dart';
import 'package:svelte_runtime/src/dom/reconciler.dart';
import 'package:svelte_runtime/src/reactivity/signals.dart';
import 'package:svelte_runtime/src/runtime.dart';
import 'package:svelte_runtime/src/unsafe_cast.dart';
import 'package:web/web.dart';

@optionalTypeArgs
typedef Template<T extends Node> = T Function();

@noInline
void assignNodes(Node? start, Node? end) {
  Effect? effect = activeEffect;

  if (effect != null && effect.nodeStart == null) {
    effect
      ..nodeStart = start
      ..nodeEnd = end;
  }
}

@noInline
@optionalTypeArgs
Template<T> template<T extends Node>(String content, [int flags = 0]) {
  bool isFragment = flags & 1 != 0;
  bool useImportNode = flags & 2 != 0;

  T? node;

  // Whether or not the first item is a text/element node. If not, we need to
  // create an additional comment node to act as `effect.nodeStart`
  bool hasStart = !content.startsWith('<!>');

  return () {
    if (hydrating) {
      assignNodes(hydrateNode, null);
      return unsafeCast<T>(hydrateNode);
    }

    T? current = node;

    if (current == null) {
      if (!hasStart) {
        content = '<!>$content';
      }

      DocumentFragment fragment = createFragment(content);

      if (isFragment) {
        current = unsafeCast<T>(fragment);
      } else {
        current = getFirstChild<T>(fragment);
      }
    }

    node = current;

    T clone = useImportNode ? importNode<T>(current) : cloneNode<T>(current);

    if (isFragment) {
      Node? start = getFirstChild<Node?>(clone);
      Node? end = getLastChild<Node?>(clone);
      assignNodes(start, end);
    } else {
      assignNodes(clone, clone);
    }

    return clone;
  };
}

@noInline
Text text(String value) {
  // We're not delegating to `template` here for performance reasons.
  if (!hydrating) {
    Text text = createText(value);
    assignNodes(text, text);
    return text;
  }

  Text node = unsafeCast<Text>(hydrateNode);

  if (node.nodeType != 3) {
    // If an {expression} is empty during SSR, we need to insert an empty text
    // node.
    before(node, node = createText());
    setHydrateNode<Node>(node);
  }

  assignNodes(node, node);
  return node;
}

@noInline
DocumentFragment comment() {
  // We're not delegating to `template` here for performance reasons.
  if (hydrating) {
    assignNodes(hydrateNode, null);
    return unsafeCast<DocumentFragment>(hydrateNode);
  }

  DocumentFragment fragment = document.createDocumentFragment();
  Comment start = createComment();
  Text anchor = createText();
  appendNodes(fragment, start, anchor);
  assignNodes(start, anchor);
  return fragment;
}

// Assign the created (or in hydration mode, traversed) dom elements to the
// current block and insert the elements into the dom (in client mode).
@noInline
void append(Node? anchor, Node node) {
  if (hydrating) {
    activeEffect!.nodeEnd = hydrateNode;
    hydrateNext<Node?>();
    return;
  }

  if (anchor == null) {
    // edge case — void `<svelte:element>` with content.
    return;
  }

  before(anchor, node);
}
