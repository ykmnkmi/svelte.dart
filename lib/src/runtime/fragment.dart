import 'dart:html';

typedef FragmentFactory = Fragment Function(List<Object?>? values);

abstract class Fragment {
  void create() {}

  void mount(Element target, Node? anchor) {}

  void intro(bool local) {}

  void outro(bool local) {}

  void detach(bool detaching) {}
}
