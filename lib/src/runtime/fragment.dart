import 'package:piko/dom.dart';

abstract class Fragment {
  void create() {}

  void mount(Element target, Node? anchor) {}

  void update(Set<String> dirty) {}

  void detach(bool detaching) {}
}
