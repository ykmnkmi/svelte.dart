import 'dart:html';

import 'src/runtime/component.dart';

export 'src/runtime/component.dart';
export 'src/runtime/dom.dart';
export 'src/runtime/scheduler.dart';

void runApp(Component component, [Element? root, Node? anchor]) {
  final tree = RenderTree(root ?? document.body!);
  component.render(tree)
    ..create()
    ..mount(tree.root, anchor);
}
