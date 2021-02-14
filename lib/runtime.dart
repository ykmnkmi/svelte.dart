import 'dart:html';

import 'src/runtime/component.dart';

export 'src/runtime/component.dart';
export 'src/runtime/dom.dart';
export 'src/runtime/scheduler.dart';

void runApp<T extends Component<T>>(Component<T> component, [Node? root]) {
  component.render()
    ..create()
    ..mount(root ?? document.body!);
}
