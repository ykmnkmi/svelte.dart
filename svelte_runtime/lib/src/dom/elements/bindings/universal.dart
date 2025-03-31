import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:svelte_runtime/src/dom/elements/bindings/shared.dart';
import 'package:svelte_runtime/src/reactivity.dart';
import 'package:web/web.dart';

void bindContentEditable(
  String property,
  HTMLElement element,
  String? Function() get,
  void Function(String value) set,
) {
  element.addEventListener(
    'input',
    () {
      JSString jsPropertyValue = element.getProperty<JSString>(property.toJS);
      set(jsPropertyValue.toDart);
    }.toJS,
  );

  renderEffect<void>(() {
    String? value = get();

    JSString jsPropertyValue = element.getProperty<JSString>(property.toJS);
    String propertyValue = jsPropertyValue.toDart;

    if (value != propertyValue) {
      if (value == null) {
        set(propertyValue);
      } else {
        element.setProperty(property.toJS, propertyValue.toJS);
      }
    }
  });
}

void bindProperty<T extends JSAny?>(
  String property,
  String eventName,
  HTMLElement element,
  void Function(T jsValue) set, [
  T Function()? get,
]) {
  void handler() {
    set(element.getProperty<T>(property.toJS));
  }

  JSExportedDartFunction jsHandler = handler.toJS;

  element.addEventListener(eventName, jsHandler);

  if (get != null) {
    renderEffect<void>(() {
      element.setProperty(property.toJS, get());
    });
  } else {
    handler();
  }

  if (element == document.body || element == window || element == document) {
    teardown<void>(() {
      element.removeEventListener(eventName, jsHandler);
    });
  }
}

void bindFocused(HTMLElement element, void Function(bool focused) set) {
  listen(element, <String>['focus', 'blur'], () {
    set(element == document.activeElement);
  });
}
