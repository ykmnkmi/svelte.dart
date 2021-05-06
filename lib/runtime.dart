import 'dart:html';

import 'src/runtime/component.dart';

export 'src/runtime/component.dart';
export 'src/runtime/dom.dart';
export 'src/runtime/scheduler.dart';

void runApp(Component component, [Node? root]) {
  component.render()
    ..create()
    ..mount(root ?? document.body!);
}
