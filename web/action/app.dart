import 'dart:html' show AnchorElement, Element, Event, Node, window;

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
  AppFragment(super.context, super.tree);

  late Link link;

  late AnchorElement a;

  bool mounted = false;

  @override
  void create() {
    a = AnchorElement(href: '#');
    a.text = 'Test';
  }

  @override
  void mount(Element target, [Node? anchor]) {
    target.insertBefore(a, anchor);

    if (!mounted) {
      link = Link(a);
      mounted = true;
    }
  }

  @override
  void detach([bool detaching = true]) {
    if (detaching) {
      a.remove();
    }

    mounted = false;
    link.destroy();
  }
}
