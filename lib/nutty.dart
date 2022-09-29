import 'dart:html';

import 'package:nutty/runtime.dart';

void Function() runApp(Component component, {Element? target, Node? anchor}) {
  target ??= unsafeCast<Element>(document.body);
  createComponent(component);
  mountComponent(component, target, anchor);
  return () {
    destroyComponent(component, true);
  };
}
