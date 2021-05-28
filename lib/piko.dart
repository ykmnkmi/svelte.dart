import 'dart:html';

import 'package:meta/dart2js.dart';

part 'src/component.dart';
part 'src/dom.dart';
part 'src/scheduler.dart';

void runApp<T extends Component<T>>(Component<T> component, [Element? root, Node? anchor]) {
  final tree = RenderTree(root ?? document.body!);
  component.render(tree)
    ..create()
    ..mount(tree.root, anchor);
}
