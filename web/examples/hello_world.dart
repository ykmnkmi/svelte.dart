library app;

import 'package:piko/piko.dart';

class App extends Component<App> {
  App() : name = 'world';

  final String name;

  @override
  Fragment<App> render(RenderTree tree) {
    return AppFragment(this, tree);
  }
}

class AppFragment extends Fragment<App> {
  AppFragment(App context, RenderTree tree) : super(context, tree);

  late Element h1;

  @override
  void create() {
    h1 = element('h1');
    h1.text = 'hello ${context.name}!';
  }

  @override
  void mount(Element target, [Node? anchor]) {
    insert(target, h1, anchor);
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(h1);
    }
  }
}
