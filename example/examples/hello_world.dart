import 'package:piko/runtime.dart';

void main() {
  runApp<App>(App());
}

class App extends Component<App> {
  var name = 'world';

  @override
  Fragment<App> render(RenderTree tree) {
    return AppFragment(this, tree);
  }
}

class AppFragment extends Fragment<App> {
  AppFragment(App context, RenderTree tree) : super(context, tree);

  late Element h11;

  @override
  void create() {
    h11 = element('h1');
    h11.text = 'Hello ${context.name}!';
  }

  @override
  void mount(Element target, [Node? anchor]) {
    insert(target, h11, anchor);
  }

  @override
  void destroy([bool detaching = true]) {
    if (detaching) {
      remove(h11);
    }
  }
}
