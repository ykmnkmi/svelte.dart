import 'dart:html';

typedef FragmentFactory = Fragment Function();

abstract class Fragment {
  void create() {}

  void mount(Element target, Node? anchor) {}

  void update(List<int> dirty) {}

  void detach(bool detaching) {}
}
