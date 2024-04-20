import 'package:svelte_runtime/src/utilities.dart';
import 'package:web/web.dart' show Element, Node;

typedef FragmentFactory = Fragment Function(List<Object?> instance);

final class Fragment {
  const Fragment({
    this.create = noop,
    this.mount = noop,
    this.update = noop,
    this.intro = noop,
    this.outro = noop,
    this.detach = noop,
  });

  final void Function() create;

  final void Function(Element target, Node? anchor) mount;

  final void Function(List<Object?> instance, int dirty) update;

  final void Function(bool local) intro;

  final void Function(bool local) outro;

  final void Function(bool detaching) detach;

  static void detachAll(List<Fragment> fragments, bool detaching) {
    for (int index = 0; index < fragments.length; index++) {
      fragments[index].detach(detaching);
    }
  }
}
