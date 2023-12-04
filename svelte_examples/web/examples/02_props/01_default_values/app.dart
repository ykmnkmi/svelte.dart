import 'dart:html';

import 'package:svelte_runtime/svelte_runtime.dart';

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
    mount: (Element target, Node? anchor) {
      mountComponent(nested0, target, anchor);
      insert(target, t, anchor);
      mountComponent(nested1, target, anchor);
      current = true;
    },
    intro: (bool local) {
      if (current) {
        return;
      }

      transitionInComponent(nested0, local);
      transitionInComponent(nested1, local);
      current = true;
    },
    outro: (bool local) {
      transitionOutComponent(nested0, local);
      transitionOutComponent(nested1, local);
      current = false;
    },
    detach: (bool detaching) {
      destroyComponent(nested0, detaching);

      if (detaching) {
        detach(t);
      }

      destroyComponent(nested1, detaching);
    },
  );
}

final class App extends Component {
  App({
    super.target,
    super.anchor,
    super.props,
    super.hydrate,
    super.intro,
  }) : super(createFragment: createFragment);
}
