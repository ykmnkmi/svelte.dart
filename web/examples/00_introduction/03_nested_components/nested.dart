import 'dart:html';

import 'package:svelte/runtime.dart';

Fragment createFragment(List<Object?> instance) {
  late Element p;

  return Fragment(
    create: () {
      p = element('p');
      setText(p, "...don't affect this element");
    },
    mount: (target, anchor) {
      insert(target, p, anchor);
    },
    detach: (detaching) {
      if (detaching) {
        remove(p);
      }
    },
  );
}

class Nested extends Component {
  Nested(Options options) {
    init(
      component: this,
      options: options,
      createFragment: createFragment,
      props: <String, int>{},
    );
  }
}
