import 'package:piko/dom.dart';

import 'src/runtime/component.dart';

export 'package:piko/dom.dart';

export 'src/runtime/component.dart';
export 'src/runtime/scheduler.dart';

void runApp<T extends Component<T>>(Component<T> component, {Element? root, Node? anchor}) {
  var tree = RenderTree();
  component.render(tree)
    ..create()
    ..mount(root ?? document.body!, anchor);
}
