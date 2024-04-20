import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart' show Element, Node;

import 'nested.dart';

Fragment createFragment(List<Object?> instance) {
  Nested nested;

  var current = false;

  nested = Nested(props: <String, Object?>{'answer': 42});

  return Fragment(
    create: () {
      createComponent(nested);
    },
    mount: (Element target, Node? anchor) {
      mountComponent(nested, target, anchor);
      current = true;
    },
    intro: (bool local) {
      if (current) {
        return;
      }

      transitionInComponent(nested, local);
      current = true;
    },
    outro: (bool local) {
      transitionOutComponent(nested, local);
      current = false;
    },
    detach: (bool detaching) {
      destroyComponent(nested, detaching);
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
