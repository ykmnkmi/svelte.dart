import 'dart:html';

import 'src/internal/component.dart';

export 'src/internal/component.dart';
export 'src/internal/dom.dart';
export 'src/internal/scheduler.dart';

void runApp(Component component, [Node? root]) {
  component.render()
    ..create()
    ..mount(root ?? document.body!);
}
