import 'package:svelte/runtime.dart';
import 'package:web/web.dart';

import 'nested.dart';

Fragment createFragment(List<Object?> instance) {
  Nested nested;

  var current = false;

  nested = Nested(props: <String, Object?>{'answer': 42});

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
  App({
    Element? target,
    Node? anchor,
    Map<String, Object?>? props,
    bool hydrate = false,
    bool intro = false,
  }) {
    init(
      component: this,
      options: (
        target: target,
        anchor: anchor,
        props: props,
        hydrate: hydrate,
        intro: intro,
      ),
      createFragment: createFragment,
    );
  }
}
