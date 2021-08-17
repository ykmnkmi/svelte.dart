import 'package:piko/dom.dart';

import 'src/component.dart';

export 'package:piko/dom.dart';

export 'src/component.dart';
export 'src/scheduler.dart';

void runApp<T extends Component<T>>(Component<T> component, {Element? root, Node? anchor}) {
  final tree = RenderTree(root ?? document.body!);
  component.render(tree)
    ..create()
    ..mount(tree.root, anchor);
}
