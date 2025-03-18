import 'dart:js_interop';

import 'package:svelte_runtime/src/dom/elements/bindings/shared.dart';
import 'package:svelte_runtime/src/dom/hydration.dart';
import 'package:svelte_runtime/src/dom/operations.dart';
import 'package:svelte_runtime/src/unsafe_cast.dart';
import 'package:web/web.dart';

// The child of a textarea actually corresponds to the defaultValue property, so
// we need to remove it upon hydration to avoid a bug when someone resets the
// form value.
void removeTextAreaChild(HTMLTextAreaElement textArea) {
  if (hydrating && getFirstChild(textArea) != null) {
    clearTextContent(textArea);
  }
}

bool listeningToFormReset = false;

void addFormResetListener() {
  if (!listeningToFormReset) {
    listeningToFormReset = true;

    document.addEventListener(
      'reset',
      (Event event) {
        // Needs to happen one tick later or else the dom properties of the form
        // elements have not updated to their reset values yet.
        Future<void>(() {
          if (!event.defaultPrevented) {
            HTMLFormElement form = unsafeCast<HTMLFormElement>(event.target);
            JSImmutableListWrapper<HTMLFormControlsCollection, HTMLElement>
            elements =
                JSImmutableListWrapper<HTMLFormControlsCollection, HTMLElement>(
                  form.elements,
                );

            for (HTMLElement element in elements) {
              void Function(bool isReset)? onReset = element.onReset__;

              if (onReset != null) {
                onReset(false);
              }
            }
          }
        });
      }.toJS,
      // In the capture phase to guarantee we get noticed of it (no possiblity
      // of stopPropagation).
      AddEventListenerOptions(capture: true),
    );
  }
}
