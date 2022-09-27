import 'package:meta/meta.dart';
import 'package:nutty/dom.dart';
import 'package:nutty/runtime.dart';

@optionalTypeArgs
void runApp(Component component, {Element? target, Node? anchor}) {
  target ??= unsafeCast<Element>(querySelector('body'));
  createComponent(component);
  mountComponent(component, target, anchor);
}
