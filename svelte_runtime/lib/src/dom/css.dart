import 'dart:js_interop';

import 'package:svelte_runtime/src/dev.dart';
import 'package:svelte_runtime/src/dom/operations.dart';
import 'package:svelte_runtime/src/environment.dart';
import 'package:svelte_runtime/src/tasks.dart';
import 'package:svelte_runtime/src/unsafe_cast.dart';
import 'package:web/web.dart';

void appendStyles(Node anchor, String hash, String code) {
  queueMicroTask(() {
    // Use `queueMicroTask` to ensure `anchor` is in the DOM, otherwise
    // getRootNode() will yield wrong results.
    Node root = anchor.getRootNode();

    Node target;

    // ShadowRoot.host is not null
    if (unsafeCast<ShadowRoot>(root).hostNullable != null) {
      target = root;
    } else {
      target =
          // Document.head is not null
          unsafeCast<Document>(root).head ??
          unsafeCast<HTMLHeadElement>(
            unsafeCast<Document>(root.ownerDocument).head,
          );
    }

    // Always querying the DOM is roughly the same perf as additionally checking
    // for presence in a map first assuming that you'll get cache hits half of
    // the time, so we just always query the dom for simplicity and code savings.
    if (unsafeCast<Element>(target).querySelector('#$hash') == null) {
      Element style = createElement<Element>('style');
      setID(style, hash);
      setTextContent(style, code);
      appendChild(target, style);

      if (assertionsEnabled) {
        registerStyle(hash, style);
      }
    }
  });
}

extension on ShadowRoot {
  @JS('host')
  external Element? get hostNullable;
}
