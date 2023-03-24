import 'package:svelte/runtime.dart';

import 'nested.dart';

Fragment createFragment(List<Object?> instance) {
  Nested nested;

  var current = false;

  nested = Nested(Options(props: <String, Object?>{'answer': 42}));

  return Fragment(
    create: () {
      createComponent(nested);
    },
    mount: (target, anchor) {
      mountComponent(nested, target, anchor);
      current = true;
    },
    intro: (local) {
      if (current) {
        return;
      }

      transitionInComponent(nested, local);
      current = true;
    },
    outro: (local) {
      transitionOutComponent(nested, local);
      current = false;
    },
    detach: (detaching) {
      destroyComponent(nested, detaching);
    },
  );
}

class App extends Component {
  App(Options options) {
    init(
      component: this,
      options: options,
      createFragment: createFragment,
      props: <String, int>{},
    );
  }
}
