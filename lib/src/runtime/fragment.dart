import 'package:meta/meta.dart';
import 'package:piko/dom.dart';

abstract class Fragment {
  @internal
  void create() {}

  @internal
  void mount(Element target, Node? anchor) {}

  @internal
  void update(Set<String> dirty) {}

  @internal
  void detach(bool detaching) {}
}
