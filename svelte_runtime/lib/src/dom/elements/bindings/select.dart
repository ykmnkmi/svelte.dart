// TODO(bindings.select): reduce `as` casts.
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:svelte_runtime/src/dom/elements/bindings/shared.dart';
import 'package:svelte_runtime/src/dom/elements/bindings/value.dart';
import 'package:svelte_runtime/src/reactivity.dart';
import 'package:svelte_runtime/src/runtime.dart';
import 'package:svelte_runtime/src/unsafe_cast.dart';
import 'package:web/web.dart';

// Selects the correct option(s) (depending on whether this is a multiple
// select).
void selectOption(
  HTMLSelectElement select,
  Object? value, [
  bool mounting = false,
]) {
  if (select.multiple) {
    selectOptions(select, value as List<Object?>);
    return;
  }

  HTMLOptionsCollection options = select.options;

  for (int i = 0; i < options.length; i += 1) {
    HTMLOptionElement option = unsafeCast<HTMLOptionElement>(options.item(i));
    Object? optionValue = getOptionValue(option);

    if (identical(optionValue, value)) {
      option.selected = true;
      return;
    }
  }

  if (!mounting) {
    select.selectedIndex = -1; // No option should be selected.
  }
}

// Selects the correct option(s) if `value` is given, and then sets up a
// mutation observer to sync the current selection to the dom when it changes.
// Such changes could for example occur when options are inside an `#each`
// block.
void initSelect(HTMLSelectElement select, [Object? Function()? get]) {
  bool mounting = true;

  effect<void Function()>(() {
    if (get != null) {
      selectOption(select, untrack<Object?>(get), mounting);
    }

    mounting = false;

    MutationObserver observer = MutationObserver(
      () {
        selectOption(select, select.value__);
        // Deliberately don't update the potential binding value, the model
        // should be preserved unless explicitly changed.
      }.toJS,
    );

    observer.observe(
      select,
      MutationObserverInit(
        // Listen to option element changes.
        childList: true,
        subtree: true, // Because of <optgroup>.
        // Listen to option element value attribute changes (doesn't get
        // notified of select value changes, because that property is not
        // reflected as an attribute).
        attributes: true,
        attributeFilter: <JSString>['value'.toJS].toJS,
      ),
    );

    return () {
      observer.disconnect();
    };
  });
}

void bindSelectValue(
  HTMLSelectElement select,
  Object? Function() get,
  void Function(Object? value) set,
) {
  bool mounting = true;

  listenToEventAndResetEvent(select, 'change', (isReset) {
    String query = isReset ? '[selected]' : ':checked';
    Object? value;

    if (select.multiple) {
      NodeList nodeList = select.querySelectorAll(query);

      value = List<Object?>.generate(
        nodeList.length,
        (i) => getOptionValue(unsafeCast<HTMLOptionElement>(nodeList.item(i))),
      );
    } else {
      Element? selectedOption =
          select.querySelector(query) ??
          // Will fall back to first non-disabled option if no option is
          // selected.
          select.querySelector('option:not([disabled])');

      if (selectedOption != null) {
        value = getOptionValue(unsafeCast<HTMLOptionElement>(selectedOption));
      }
    }

    set(value);
  });

  // Needs to be an effect, not a renderEffect, so that in case of each loops
  // the logic runs after the each block has updated.
  effect<void>(() {
    Object? value = get();
    selectOption(select, value, mounting);

    // Mounting and value undefined -> take selection from dom.
    // TODO(bindings.select): undefind check replaced with null.
    if (mounting && value == null) {
      HTMLOptionElement? selectedOption = unsafeCast<HTMLOptionElement?>(
        select.querySelector(':checked'),
      );

      if (selectedOption != null) {
        value = getOptionValue(selectedOption);
        set(value);
      }
    }

    select.value__ = value;
    mounting = false;
  });

  // Don't pass get, we already initialize it in the effect above.
  initSelect(select);
}

void selectOptions(HTMLSelectElement select, List<Object?> values) {
  HTMLOptionsCollection options = select.options;

  for (int i = 0; i < options.length; i += 1) {
    HTMLOptionElement option = unsafeCast<HTMLOptionElement>(options.item(i));
    option.selected = values.contains(getOptionValue(option));
  }
}

Object? getOptionValue(HTMLOptionElement option) {
  if (option.has('__value')) {
    return option.value__;
  }

  return option.value;
}
