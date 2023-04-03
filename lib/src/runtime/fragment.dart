import 'dart:html';

void _update(List<Object?> context, List<int> dirty) {}

void _transition(bool local) {}

class Fragment {
  const Fragment({
    required this.create,
    required this.mount,
    this.update = _update,
    this.intro = _transition,
    this.outro = _transition,
    required this.detach,
  });

  final void Function() create;

  final void Function(Element target, Node? anchor) mount;

  final void Function(List<Object?> context, List<int> dirty) update;

  final void Function(bool local) intro;

  final void Function(bool local) outro;

  final void Function(bool detaching) detach;

  static void detachAll(List<Fragment> fragments, bool detaching) {
    for (var fragment in fragments) {
      fragment.detach(detaching);
    }
  }
}
