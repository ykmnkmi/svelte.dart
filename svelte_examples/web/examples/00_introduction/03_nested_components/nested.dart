import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart' show Element, Node;

Fragment createFragment(List<Object?> instance) {
  late Element p;

  return Fragment(
    create: () {
      p = element('p');
      setText(p, "...don't affect this element");
    },
    mount: (Element target, Node? anchor) {
      insert(target, p, anchor);
    },
    detach: (bool detaching) {
      if (detaching) {
        detach(p);
      }
    },
  );
}

final class Nested extends Component {
  Nested({
    super.target,
    super.anchor,
    super.props,
    super.hydrate,
    super.intro,
  }) : super(createFragment: createFragment);
}
