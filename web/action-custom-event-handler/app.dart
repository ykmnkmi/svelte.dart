import 'package:piko/runtime.dart';

void handleFoo(String bar) {
  print(bar);
}

class Foo extends Action<ButtonElement, void Function()> {
  Foo(super.node, void Function() parameter);
}

class App extends Component {
  App({required this.bar});

  String bar;

  @override
  Fragment<App> createFragment(Context tree) {
    return AppFragment(tree, this);
  }
}

class AppFragment extends Fragment<App> {
  AppFragment(super.context, super.component);

  late Foo foo;

  late ButtonElement button;

  bool mounted = false;

  @override
  void create() {
    button = element<ButtonElement>('button');
    content(button, 'foo');
  }

  @override
  void mount(Element target, [Node? anchor]) {
    insert(target, button, anchor);

    if (!mounted) {
      foo = Foo(button, () => handleFoo(component.bar));
      mounted = true;
    }
  }

  @override
  void update(Set<String> aspects) {
    if (aspects.contains('bar')) {
      foo.update(() => handleFoo(component.bar));
    }
  }

  @override
  void detach([bool detaching = true]) {
    if (detaching) {
      remove(button);
    }

    mounted = false;
    foo.destroy();
  }
}
