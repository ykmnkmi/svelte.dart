import 'package:meta/meta.dart';
import 'package:svelte_runtime/src/dom/operations.dart';
import 'package:svelte_runtime/src/shared.dart';
import 'package:svelte_runtime/src/unsafe_cast.dart';
import 'package:web/web.dart';

// Use this variable to guard everything related to hydration code so it can be
// treeshaken out if the user doesn't use the `hydrate` method and these code
// paths are therefore not needed.
bool hydrating = false;

void setHydrating(bool value) {
  hydrating = value;
}

// The node that is currently being hydrated. This starts out as the first node
// inside the opening <!--[--> comment, and updates each time a component calls
// `child(...)` or `sibling(...)`. When entering a block (e.g. `{#if ...}`),
// `hydrateNode` is the block opening comment; by the time we leave the block it
// is the closing comment, which serves as the block's anchor.
Node? hydrateNode;

@optionalTypeArgs
T setHydrateNode<T extends Node?>(Node? node) {
  if (node == null) {
    // ignore: avoid_print
    print('WRN_HYDRATION_MISMATCH');
    throw hydrationError;
  }

  hydrateNode = node;
  return unsafeCast<T>(node);
}

@optionalTypeArgs
T hydrateNext<T extends Node?>() {
  return setHydrateNode<T>(
    getNextSibling<Node?>(unsafeCast<Node>(hydrateNode)),
  );
}

void reset(Node node) {
  if (!hydrating) {
    return;
  }

  // If the node has remaining siblings, something has gone wrong.
  if (getNextSibling<Node?>(node) != null) {
    // ignore: avoid_print
    print('ERR_HYDRATION_MISMATCH');
    throw hydrationError;
  }

  hydrateNode = node;
}

void next([int count = 1]) {
  if (hydrating) {
    int i = count;
    Node node = unsafeCast<Node>(hydrateNode);

    while (i-- > 0) {
      node = getNextSibling<Node>(node);
    }

    hydrateNode = node;
  }
}

void hydrateTemplate(HTMLTemplateElement template) {
  if (hydrating) {
    hydrateNode = template.content;
  }
}

/// Removes all nodes starting at `hydrateNode` up until the next hydration end
/// comment.
Comment removeNodes() {
  int depth = 0;
  Node node = unsafeCast<Node>(hydrateNode);

  while (true) {
    if (node.nodeType == 8) {
      Comment comment = unsafeCast<Comment>(node);
      String data = comment.data;

      if (data == hydrationEnd) {
        if (depth == 0) {
          return comment;
        }

        depth--;
      } else if (data == hydrationStart || data == hydrationStartElse) {
        depth++;
      }
    }

    Node next = getNextSibling<Node>(node);
    remove(node);
    node = next;
  }
}
