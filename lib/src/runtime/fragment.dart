import 'dart:html';

void defaultUpdate(List<int> dirty) {}

void defaultTransition(bool local) {}

class Fragment {
  const Fragment({
    required this.create,
    required this.mount,
    this.update = defaultUpdate,
    this.intro = defaultTransition,
    this.outro = defaultTransition,
    required this.detach,
  });

  final void Function() create;

  final void Function(Element target, Node? anchor) mount;

  final void Function(List<int> dirty) update;

  final void Function(bool local) intro;

  final void Function(bool local) outro;

  final void Function(bool detaching) detach;
}
