library piko.runtime;

import 'package:meta/meta.dart';
import 'package:piko/dom.dart';

export 'package:piko/dom.dart';

part 'src/runtime/action.dart';
part 'src/runtime/component.dart';
part 'src/runtime/scheduler.dart';

void runApp<T extends Component>(Component component, {Element? root}) {
  var target = root ?? document.body!;
  var context = Context(target);
  component.createFragment(context)
    ..create()
    ..mount(target);
}
