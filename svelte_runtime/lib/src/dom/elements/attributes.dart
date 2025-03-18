import 'dart:js_interop';

import 'package:svelte_runtime/src/dom/elements/bindings/shared.dart';
import 'package:svelte_runtime/src/dom/elements/misc.dart';
import 'package:svelte_runtime/src/dom/hydration.dart';
import 'package:svelte_runtime/src/dom/operations.dart';
import 'package:svelte_runtime/src/environment.dart';
import 'package:svelte_runtime/src/tasks.dart';
import 'package:web/web.dart';

// The value/checked attribute in the template actually corresponds to the
// defaultValue property, so we need to remove it upon hydration to avoid a bug
// when someone resets the form value.
void removeInputDefaults(HTMLInputElement input) {
  if (!hydrating) {
    return;
  }

  bool alreadyRemoved = false;

  // We try and remove the default attributes later, rather than sync during
  // hydration. Doing it sync during hydration has a negative impact on
  // performance, but deferring the work in an idle task alleviates this
  // greatly. If a form reset event comes in before the idle callback, then we
  // ensure the input defaults are cleared just before.
  void removeDefaults() {
    if (alreadyRemoved) {
      return;
    }

    alreadyRemoved = true;

    // Remove the attributes but preserve the values.
    if (input.hasAttribute('value')) {
      String value = input.value;
      setAttribute(input, 'value', null);
      input.value = value;
    }

    if (input.hasAttribute('checked')) {
      bool checked = input.checked;
      setAttribute(input, 'checked', null);
      input.checked = checked;
    }
  }

  input.onReset__ = (bool isReset) {
    removeDefaults();
  };

  queueMicroTask(removeDefaults);
  addFormResetListener();
}

void setAttribute(
  Element element,
  String attribute,
  String? value, [
  bool skipWarning = false,
]) {
  Map<String, String?> attributes;

  Map<String, String?>? currentAttributes = element.attributes__;

  if (currentAttributes != null) {
    attributes = currentAttributes;
  } else {
    attributes = <String, String?>{};
    element.attributes__ = attributes;
  }

  if (hydrating) {
    attributes[attribute] = element.getAttribute(attribute);

    if (attribute == 'src' ||
        attribute == 'srcset' ||
        (attribute == 'href' && element.nodeName == 'LINK')) {
      if (!skipWarning) {
        checkSourceHydratioin(element, attribute, value ?? '');
      }

      // If we reset these attributes, they would result in another network
      // request, which we want to avoid. We assume they are the same between
      // client and server as checking if they are equal is expensive (we can't
      // just compare the strings as they can be different between client and
      // server but result in the same url, so we would need to create hidden
      // anchor elements to compare them).
      return;
    }
  }

  if (attributes[attribute] == (attributes[attribute] = value)) {
    return;
  }

  if (attribute == 'style') {
    // reset styles to force style: directive to update.
    element.styles__ = <String, String?>{};
  }

  if (attribute == 'loading') {
    element.lazy__ = value;
  }

  if (value == null) {
    element.removeAttribute(attribute);
  } else {
    element.setAttribute(attribute, value);
  }
}

void checkSourceHydratioin(Element element, String attribute, String value) {
  if (!assertionsEnabled) {
    return;
  }

  if (attribute == 'srcset' && sourceSetEqual(element, value)) {
    return;
  }

  if (sourceEqual(element.getAttribute(attribute) ?? '', value)) {
    return;
  }

  // ignore: avoid_print
  print('WRN_HYDRATION_ATTRIBUTE_CHANGED');
}

bool sourceEqual(String source, String url) {
  return source == url || Uri.parse(source) == Uri.parse(url);
}

List<List<String>> splitSourceSet(String set) {
  return set.split(',').map<List<String>>((source) {
    return source.trim().split(' ').where((part) {
      return part.isNotEmpty;
    }).toList();
  }).toList();
}

bool sourceSetEqual(Element element, String sourceSet) {
  List<List<String>> elementUrls = splitSourceSet(element.sourceSet);
  List<List<String>> urls = splitSourceSet(sourceSet);

  if (elementUrls.length != urls.length) {
    return false;
  }

  for (int i = 0; i < urls.length; i += 1) {
    if (urls[i][1] != elementUrls[i][1] ||
        // TODO(attributes): check link and build_runner.
        // We need to test both ways because Vite will create an a full URL with
        // `new URL(asset, import.meta.url).href` for the client when
        // `base: './'`, and the relative URLs inside srcset are not
        // automatically resolved to absolute URLs by browsers (in contrast to
        // img.src). This means both SSR and DOM code could contain relative or
        // absolute URLs.
        !(sourceEqual(elementUrls[i][0], urls[i][0]) ||
            sourceEqual(urls[i][0], elementUrls[i][0]))) {
      return false;
    }
  }

  return true;
}

extension on Element {
  @JS('srcset')
  external String get sourceSet;
}
