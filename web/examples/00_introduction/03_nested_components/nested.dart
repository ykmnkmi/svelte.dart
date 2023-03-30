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
  Nested({
    Element? target,
    Node? anchor,
    Map<String, Object?>? props,
    bool hydrate = false,
    bool intro = false,
  }) {
    init(
      component: this,
      options: Options(
        target: target,
        anchor: anchor,
        props: props,
        hydrate: hydrate,
        intro: intro,
      ),
      createFragment: createFragment,
      props: <String, int>{},
    );
  }
}
