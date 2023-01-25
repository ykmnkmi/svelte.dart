import 'dart:html' show Element, Node, document;

import 'package:svelte/src/runtime/component.dart';
import 'package:svelte/src/runtime/utilities.dart';

void runApp(Component component, {Element? target, Node? anchor}) {
  target ??= unsafeCast<Element>(document.body);
  createComponent(component);
  mountComponent(component, target, anchor);
}
