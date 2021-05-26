import 'dart:html';

import 'package:meta/dart2js.dart';
import 'package:meta/meta.dart';

part 'src/runtime/component.dart';
part 'src/runtime/dom.dart';
part 'src/runtime/scheduler.dart';

void runApp<T extends Component<T>>(Component<T> component, [Element? root, Node? anchor]) {
  final tree = RenderTree(root ?? document.body!);
  component.render(tree)
    ..create()
    ..mount(tree.root, anchor);
}
