import 'package:svelte_runtime/src/dom/blocks/render.dart';
import 'package:svelte_runtime/src/dom/hydration.dart';
import 'package:svelte_runtime/src/reactivity.dart';
import 'package:svelte_runtime/src/shared.dart';
import 'package:svelte_runtime/src/unsafe_cast.dart';
import 'package:web/web.dart';

typedef RenderBranch = void Function(Render callback, [bool flag]);

void ifBlock(
  Node node,
  void Function(RenderBranch render) callback, [
  bool elseIf = false,
]) {
  if (hydrating) {
    hydrateNext();
  }

  Comment anchor = unsafeCast<Comment>(node);

  Effect? consequentEffect;

  Effect? alternateEffect;

  Object? condition = #condition;

  int flags = elseIf ? Flag.effectTransparent : 0;

  bool hasBranch = false;

  void updateBranch(bool? newCondition, Render? callback) {
    if (condition == (condition = newCondition)) {
      return;
    }

    // Whether or not there was a hydration mismatch. Needs to be a `let` or
    // else it isn't treeshaken out.
    bool mismatch = false;

    if (hydrating) {
      bool isElse = anchor.data == hydrationStart;

      if ((condition ?? false) == isElse) {
        // Hydration mismatch: remove everything inside the anchor and start
        // fresh. This could happen with `{#if browser}...{/if}`, for example.
        anchor = removeNodes();

        setHydrateNode(anchor);
        setHydrating(false);
        mismatch = true;
      }
    }

    if (condition == true || condition == #condition) {
      if (consequentEffect != null) {
        resumeEffect(consequentEffect!);
      } else if (callback != null) {
        consequentEffect = branch<void>(() {
          callback(anchor);
        });
      }

      if (alternateEffect != null) {
        pauseEffect(alternateEffect!, () {
          alternateEffect = null;
        });
      }
    } else {
      if (alternateEffect != null) {
        resumeEffect(alternateEffect!);
      } else if (callback != null) {
        alternateEffect = branch<void>(() {
          callback(anchor);
        });
      }

      if (consequentEffect != null) {
        pauseEffect(consequentEffect!, () {
          consequentEffect = null;
        });
      }
    }

    if (mismatch) {
      // Continue in hydrating mode.
      setHydrating(true);
    }
  }

  void setBranch(Render callback, [bool flag = true]) {
    hasBranch = true;
    updateBranch(flag, callback);
  }

  block<void>(() {
    hasBranch = false;
    callback(setBranch);

    if (!hasBranch) {
      updateBranch(null, null);
    }
  }, flags);

  if (hydrating) {
    anchor = unsafeCast<Comment>(hydrateNode);
  }
}
