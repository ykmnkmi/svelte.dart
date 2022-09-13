import 'package:meta/meta.dart';
import 'package:piko/dom.dart';
import 'package:piko/runtime.dart';

@optionalTypeArgs
void runApp<T extends Component>(Component component, {Element? target, Node? anchor}) {
  target ??= unsafeCast<Element>(querySelector('body'));
  createComponent(component);
  mountComponent(component, target, anchor);
}
