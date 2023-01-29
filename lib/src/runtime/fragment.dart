import 'dart:html';

import 'package:svelte/src/runtime/state.dart';

typedef FragmentFactory = Fragment Function(Instance instance);

abstract class Fragment {
  void create() {}

  void mount(Element target, Node? anchor) {}

  void intro(bool local) {}

  void outro(bool local) {}

  void detach(bool detaching) {}
}
