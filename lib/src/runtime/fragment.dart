import 'dart:html';

import 'package:svelte/src/runtime/component.dart';

abstract class Fragment {
  void create() {}

  void mount(Element target, Node? anchor) {}

  void update(Instance instance, int dirty) {}

  void intro(bool local) {}

  void outro(bool local) {}

  void detach(bool detaching) {}
}
