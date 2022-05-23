import 'package:piko/runtime.dart';

class Link extends Action<AnchorElement, Object?> {
  Link(super.node) {
    node.addEventListener('click', onClick);
  }

  void onClick(Event event) {
    event.preventDefault();
    window.history.pushState(null, '', node.href);
  }

  @override
  void destroy() {
    node.removeEventListener('click', onClick);
  }
}

class App extends Component {
  @override
  Fragment<App> createFragment(Context tree) {
    return AppFragment(tree, this);
  }
}

class AppFragment extends Fragment<App> {
  AppFragment(super.context, super.component);

  late Link link;

  late AnchorElement a;

  bool mounted = false;

  @override
  void create() {
    a = element<AnchorElement>('a');
    attribute(a, 'href', '#');
    content(a, 'Test');
  }

  @override
  void mount(Element target, [Node? anchor]) {
    insert(target, a, anchor);

    if (!mounted) {
      link = Link(a);
      mounted = true;
    }
  }

  @override
  void detach([bool detaching = true]) {
    if (detaching) {
      remove(a);
    }

    mounted = false;
    link.destroy();
  }
}
