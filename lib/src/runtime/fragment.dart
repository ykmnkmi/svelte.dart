import 'package:meta/dart2js.dart';
import 'package:piko/dom.dart';

abstract class Fragment {
  @noInline
  void create() {}

  @noInline
  void mount(Element target, Node? anchor) {}

  @noInline
  void update(Set<String> dirty) {}

  @noInline
  void detach(bool detaching) {}
}
