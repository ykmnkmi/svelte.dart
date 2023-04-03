import 'dart:html';

import 'package:svelte/runtime.dart';

import 'nested.dart';

Fragment createFragment(List<Object?> instance) {
  Nested nested0;
  late Text t;
  Nested nested1;

  nested0 = Nested(props: <String, Object?>{'answer': 42});
  nested1 = Nested();

  var current = false;

  return Fragment(
    create: () {
      createComponent(nested0);
      t = space();
      createComponent(nested1);
    },
    mount: (target, anchor) {
      mountComponent(nested0, target, anchor);
      insert(target, t, anchor);
      mountComponent(nested1, target, anchor);
      current = true;
    },
    intro: (local) {
      if (current) {
        return;
      }

      transitionInComponent(nested0, local);
      transitionInComponent(nested1, local);
      current = true;
    },
    outro: (local) {
      transitionOutComponent(nested0, local);
      transitionOutComponent(nested1, local);
      current = false;
    },
    detach: (detaching) {
      destroyComponent(nested0, detaching);

      if (detaching) {
        detach(t);
      }

      destroyComponent(nested1, detaching);
    },
  );
}

class App extends Component {
  App({
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
