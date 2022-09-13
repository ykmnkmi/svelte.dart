import 'package:piko/dom.dart';

typedef FragmentFactory = Fragment Function();

abstract class Fragment {
  void create() {}

  void mount(Element target, Node? anchor) {}

  void detach(bool detaching) {}
}
