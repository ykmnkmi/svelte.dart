import 'dart:html';

export 'src/runtime/dom.dart';

abstract class Component<T> {
  Fragment<T> createFragment();
}

abstract class Fragment<T> {
  T get context;

  void create() {}

  void mount(Element target) {}

  void update([String aspect]) {}

  void detach(bool removing) {}
}

void runApp<T>(Component<T> component, [Node root]) {
  component.createFragment()
    ..create()
    ..mount(root ?? document.body);
}
