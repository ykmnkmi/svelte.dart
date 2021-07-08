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
      : nested = Nested(),
        super(context, tree) {
    nestedFragment = nested.render(tree);
  }

  final Nested nested;

  late Element p;

  late Text t;

  late Fragment<Nested> nestedFragment;

  late Text t2;

  @override
  void create() {
    p = element('p');
    t = text('This is a ');
    createFragment(nestedFragment);
    t2 = text('.');
  }

  @override
  void mount(Element target, [Node? anchor]) {
    insert(target, p, anchor);
    append(p, t);
    mountFragment(nestedFragment, p);
    append(p, t2);
  }

  @override
  void detach([bool detaching = false]) {
    if (detaching) {
      remove(p);
    }

    detachFragment(nestedFragment);
  }
}
