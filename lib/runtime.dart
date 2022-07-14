import 'package:meta/meta.dart';
import 'package:piko/dom.dart';
import 'package:piko/src/runtime/component.dart';

export 'package:piko/src/runtime/action.dart';
export 'package:piko/src/runtime/component.dart';
export 'package:piko/src/runtime/fragment.dart';

@optionalTypeArgs
void runApp<T extends Component>(Component component, {Element? target}) {
  target ??= unsafeCast<Element>(querySelector('body'));

  component
    ..create()
    ..mount(target, null);
}
