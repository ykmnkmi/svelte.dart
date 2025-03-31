import 'package:svelte_runtime/src/dom/hydration.dart';
import 'package:svelte_runtime/src/dom/operations.dart';
import 'package:svelte_runtime/src/dom/reconciler.dart';
import 'package:svelte_runtime/src/dom/template.dart';
import 'package:svelte_runtime/src/environment.dart';
import 'package:svelte_runtime/src/reactivity.dart';
import 'package:svelte_runtime/src/shared.dart';
import 'package:svelte_runtime/src/unsafe_cast.dart';
import 'package:web/web.dart';

void checkHash(String? serverHash, String value) {
  if (serverHash == null || serverHash == hash(value)) {
    return;
  }

  // ignore: avoid_print
  print('WRN_HYDRATION_HTML_CHANGED');
}

void html(
  Node node,
  String Function() getValue,
  bool svg,
  bool mathml, [
  bool skipWarning = false,
]) {
  Node anchor = node;

  String value = '';

  Effect? effect;

  block<void>(() {
    String newValue = getValue();

    if (value == newValue) {
      if (hydrating) {
        hydrateNext<Node?>();
      }

      return;
    }

    value = newValue;

    if (effect != null) {
      destroyEffect(effect!);
      effect = null;
    }

    if (value == '') {
      return;
    }

    effect = branch<void>(() {
      if (hydrating) {
        Comment comment = unsafeCast<Comment>(hydrateNode);

        // We're deliberately not trying to repair mismatches between server and
        // client, as it's costly and error-prone (and it's an edge case to have
        // a mismatch anyway).
        String hash = comment.data;
        Comment? next = hydrateNext<Comment?>();
        Comment? last = next;

        while (next != null && (next.nodeType != 8 || next.data != '')) {
          last = next;
          next = getNextSibling<Comment?>(next);
        }

        if (next == null) {
          // ignore: avoid_print
          print('WRN_HYDRATION_MISMATCH');
          throw hydrationError;
        }

        if (assertionsEnabled && !skipWarning) {
          checkHash(hash, value);
        }

        assignNodes(hydrateNode, last);
        anchor = setHydrateNode<Node>(next);
        return;
      }

      String html = value;

      if (svg) {
        html = '<svg>$html</svg>';
      } else if (mathml) {
        html = '<math>$html</math>';
      }

      // Don't use `createFragmentWithScript` here because that would mean
      // script tags are executed.
      // @html is basically `.innerHTML = ...` and that doesn't execute scripts
      // either due to security reasons.
      Node node = createFragment(html);

      if (svg || mathml) {
        node = getFirstChild<Node>(node);
      }

      Node? start = getFirstChild<Node?>(node);
      Node? end = getLastChild<Node?>(node);
      assignNodes(start, end);

      if (svg || mathml) {
        Node? child = getFirstChild<Node?>(node);

        while (child != null) {
          before(anchor, child);
        }
      } else {
        before(anchor, node);
      }
    });
  });
}
