import 'js_dom.dart';

export 'js_dom.dart';

part 'src/component.dart';
part 'src/scheduler.dart';

void runApp<T extends Component<T>>(Component<T> component, [Element? root, Node? anchor]) {
  final tree = RenderTree(root ?? document.body);
  component.render(tree)
    ..create()
    ..mount(tree.root, anchor);
}
