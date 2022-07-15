import 'package:meta/meta.dart';
import 'package:piko/dom.dart';
import 'package:piko/src/runtime/fragment.dart';

export 'package:piko/src/runtime/action.dart';
export 'package:piko/src/runtime/component.dart';
export 'package:piko/src/runtime/fragment.dart';

@optionalTypeArgs
void runApp<T extends Fragment>(Fragment fragment, {Element? target}) {
  target ??= unsafeCast<Element>(querySelector('body'));

  fragment
    ..create()
    ..mount(target, null);
}
