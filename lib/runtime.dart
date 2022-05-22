import 'dart:html' show Element, document;

import 'package:piko/src/runtime/component.dart';

export 'src/runtime/action.dart';
export 'src/runtime/component.dart';
export 'src/runtime/scheduler.dart';

void runApp<T extends Component>(Component component, //
    {Element? root}) {
  var target = root ?? document.body!;
  var context = Context(target);
  component.createFragment(context)
    ..create()
    ..mount(target);
}
