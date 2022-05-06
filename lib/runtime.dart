import 'package:piko/dom.dart';
import 'package:piko/src/runtime/component.dart';

export 'src/runtime/component.dart';
export 'src/runtime/scheduler.dart';

void runApp<T extends Component<T>>(Component<T> component, {Element? root, Node? anchor}) {
  var tree = RenderTree();
  component.createFragment(tree)
    ..create()
    ..mount(root ?? document.body!, anchor);
}
