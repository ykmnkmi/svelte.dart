import 'dart:html';

import 'src/internal/component.dart';

export 'src/internal/component.dart';
export 'src/internal/dom.dart';
export 'src/internal/scheduler.dart';

void runApp<T extends Component<T>>(Component<T> component, [Node? root]) {
  component.render()
    ..create()
    ..mount(root ?? document.body!);
}
