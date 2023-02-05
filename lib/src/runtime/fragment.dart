import 'dart:html';

abstract class Fragment {
  void create() {}

  void mount(Element target, Node? anchor) {}

  void update(List<int> dirty) {}

  void intro(bool local) {}

  void outro(bool local) {}

  void detach(bool detaching) {}
}
