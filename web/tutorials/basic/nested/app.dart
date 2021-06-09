import 'package:piko/piko.dart';

import 'nested.dart';

class App extends Component<App> {
  @override
  Fragment<App> render(RenderTree tree) {
    return AppFragment(this, tree);
  }
}

class AppFragment extends Fragment<App> {
  AppFragment(App context, RenderTree tree)
      : nested1 = Nested(),
        super(context, tree) {
    nested1Fragment = nested1.render(tree);
  }

  final Nested nested1;

  late Element p1;

  late Text t1;

  late Fragment<Nested> nested1Fragment;

  late Text t2;

  @override
  void create() {
    p1 = element('p');
    t1 = text('This is a ');
    nested1Fragment.create();
    t2 = text('.');
  }

  @override
  void mount(Element target, [Node? anchor]) {
    insert(target, p1, anchor);
    append(p1, t1);
    nested1Fragment.mount(p1);
    append(p1, t2);
  }

  @override
  void detach([bool detaching = false]) {
    if (detaching) {
      remove(p1);
    }

    nested1Fragment.detach();
  }
}
