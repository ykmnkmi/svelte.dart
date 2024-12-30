import 'package:web/web.dart' show Element, Node;

typedef FragmentFactory = Fragment Function(List<Object?> instance);

base class Fragment {
  static const Fragment empty = Fragment();

  const Fragment();

  void create(List<Object?> instance) {}

  void claim(List<Node> nodes) {}

  void mount(List<Object?> instance, Element target, Node? anchor) {}

  void update(List<Object?> instance, int dirty) {}

  void intro(bool local) {}

  void outro(bool local) {}

  void detach(bool detaching) {}

  static void detachAll(List<Fragment> fragments, bool detaching) {
    for (int index = 0; index < fragments.length; index++) {
      fragments[index].detach(detaching);
    }
  }
}
