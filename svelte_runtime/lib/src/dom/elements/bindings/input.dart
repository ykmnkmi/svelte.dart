// TODO(bindings.input): try to split to `String` and `T` variants, reducing
//  `as` casts.
library;

import 'dart:math' show min;

import 'package:svelte_runtime/src/dom/elements/bindings/shared.dart';
import 'package:svelte_runtime/src/dom/elements/bindings/value.dart';
import 'package:svelte_runtime/src/dom/hydration.dart';
import 'package:svelte_runtime/src/environment.dart';
import 'package:svelte_runtime/src/reactivity.dart';
import 'package:svelte_runtime/src/runtime.dart';
import 'package:svelte_runtime/src/tasks.dart';
import 'package:svelte_runtime/src/unsafe_cast.dart';
import 'package:web/web.dart';

void bindValue(
  HTMLElement element,
  Object? Function() get,
  void Function(Object? value) set,
) {
  HTMLInputElement input = unsafeCast<HTMLInputElement>(element);

  listenToEventAndResetEvent(input, 'input', (isReset) {
    if (assertionsEnabled && input.type == 'checkbox') {
      // TODO(bindings.error): should this happen in production too?
      throw StateError('ERR_BIND_INVALID_CHECKBOX_VALUE');
    }

    String inputValue = isReset ? input.defaultValue : input.value;
    Object? value = isNumberLike(input) ? toNumber(inputValue) : inputValue;

    set(value);

    // Respect any validation in accessors.
    if (value != (value = get())) {
      int? start = input.selectionStart;
      int? end = input.selectionEnd;
      input.value = value == null ? '' : '$value';

      // Restore selection.
      if (end != null) {
        input.selectionStart = start;
        input.selectionEnd = min(end, input.value.length);
      }
    }
  });

  if (
  // If we are hydrating and the value has since changed
  // then use the updated value from the input instead.
  hydrating && input.defaultValue != input.value ||
      // If defaultValue is set, then value == defaultValue.
      // TODO(S6): remove input.value check and set to empty string?
      untrack<Object?>(get) == null && input.value.isNotEmpty) {
    set(isNumberLike(input) ? toNumber(input.value) : input.value);
  }

  renderEffect<void>(() {
    if (assertionsEnabled && input.type == 'checkbox') {
      // TODO(bindings.dev): should this happen in production too?
      throw StateError('ERR_BIND_INVALID_CHECKBOX_VALUE');
    }

    Object? value = get();

    if (isNumberLike(input) && value == toNumber(input.value)) {
      // Handles 0 vs 00 case.
      // See https://github.com/sveltejs/svelte/issues/9959.
      return;
    }

    if (input.type == 'date' &&
        (value is String ? value.isEmpty : value == null) &&
        input.value.isEmpty) {
      // Handles the case where a temporarily invalid date is set (while typing,
      // for example with a leading 0 for the day) and prevents this state from
      // clearing the other parts of the date input.
      // See https://github.com/sveltejs/svelte/issues/7897.
      return;
    }

    // Don't set the value of the input if it's the same to allow minlength to
    // work properly.
    if (value != input.value) {
      input.value = value == null ? '' : '$value';
    }
  });
}

Set<List<HTMLInputElement>> pending = <List<HTMLInputElement>>{};

void bindCheckedGroup<T>(
  List<HTMLInputElement> inputs,
  List<int>? groupIndex,
  HTMLInputElement input,
  List<T> Function() get,
  void Function(List<T> values) set,
) {
  bindGroup(inputs, groupIndex, input, get, (value) {
    set((value as List<Object?>).cast<T>());
  });
}

void bindRadioGroup<T>(
  List<HTMLInputElement> inputs,
  List<int>? groupIndex,
  HTMLInputElement input,
  T Function() get,
  void Function(T value) set,
) {
  bindGroup(inputs, groupIndex, input, get, (value) {
    set(value as T);
  });
}

void bindGroup(
  List<HTMLInputElement> inputs,
  List<int>? groupIndex,
  HTMLInputElement input,
  Object? Function() get,
  void Function(Object? value) set,
) {
  bool isCheckBox = input.getAttribute('type') == 'checkbox';
  List<HTMLInputElement> bindingGroup = inputs;

  // Needs to be let or related code isn't treeshaken out if it's always false.
  bool hydrationMismatch = false;

  if (groupIndex != null && groupIndex.isNotEmpty) {
    throw UnsupportedError('Group indexes.');
  }

  bindingGroup.add(input);

  listenToEventAndResetEvent(
    input,
    'change',
    (_) {
      Object? value = input.value__;

      if (isCheckBox) {
        value = getBindingGroupValue(bindingGroup, value, input.checked);
      }

      set(value);
    },
    (_) {
      // TODO(bindings.group): pass T?
      // TODO(bindings.group): better default value handling.
      set(isCheckBox ? <Object?>[] : null);
    },
  );

  renderEffect<void>(() {
    Object? value = get();

    // If we are hydrating and the value has since changed, then use the update
    // value from the input instead.
    if (hydrating && input.defaultChecked != input.checked) {
      hydrationMismatch = true;
      return;
    }

    if (isCheckBox) {
      List<Object?> values = value as List<Object?>? ?? <Object?>[];
      input.checked = values.contains(input.value__);
    } else {
      input.checked = identical(input.value__, value);
    }
  });

  teardown<void>(() {
    int index = bindingGroup.indexOf(input);

    if (index != -1) {
      bindingGroup.removeAt(index);
    }
  });

  if (pending.add(bindingGroup)) {
    queueMicroTask(() {
      // Necessary to maintain binding group order in all insertion scenarios.
      bindingGroup.sort((a, b) => (a.compareDocumentPosition(b) == 4 ? -1 : 1));
      pending.remove(bindingGroup);
    });
  }

  queueMicroTask(() {
    if (hydrationMismatch) {
      Object? value;

      if (isCheckBox) {
        value = getBindingGroupValue(bindingGroup, value, input.checked);
      } else {
        for (int i = 0; i < bindingGroup.length; i++) {
          HTMLInputElement hydrationInput = bindingGroup[i];

          if (hydrationInput.checked) {
            value = hydrationInput.value__;
          }
        }
      }

      set(value);
    }
  });
}

void bindChecked(
  HTMLInputElement input,
  bool? Function() get,
  void Function(bool value) set,
) {
  listenToEventAndResetEvent(input, 'change', (isReset) {
    bool value = isReset ? input.defaultChecked : input.checked;
    set(value);
  });

  if (
  // If we are hydrating and the value has since changed,
  // then use the update value from the input instead.
  (hydrating && input.defaultChecked != input.checked) ||
      // If defaultChecked is set, then checked == defaultChecked
      untrack<bool?>(get) == null) {
    set(input.checked);
  }

  renderEffect(() {
    bool? value = get();
    input.checked = value == true;
  });
}

List<Object?> getBindingGroupValue(
  List<HTMLInputElement> group,
  Object? value,
  bool checked,
) {
  Set<Object?> values = <Object?>{};

  for (int i = 0; i < group.length; i++) {
    HTMLInputElement input = group[i];

    if (input.checked) {
      values.add(input.value__);
    }
  }

  if (!checked) {
    values.remove(value);
  }

  return List<Object?>.of(values);
}

bool isNumberLike(HTMLInputElement input) {
  String type = input.type;
  return type == 'number' || type == 'range';
}

int? toNumber(String value) {
  return value == '' ? null : int.parse(value);
}

void bindFiles(
  HTMLInputElement input,
  FileList? Function() get,
  void Function(FileList? files) set,
) {
  listenToEventAndResetEvent(input, 'change', (_) {
    set(input.files);
  });

  renderEffect<void>(() {
    input.files = get();
  });
}
