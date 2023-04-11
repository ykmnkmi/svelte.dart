import 'dart:html';

import 'package:svelte/runtime.dart';

Fragment createFragment(List<Object?> instance) {
  late Element h1;

  return Fragment(
    create: () {
      h1 = element('h1');
      setText(h1, 'Hello $name!');
    },
    mount: (target, anchor) {
      insert(target, h1, anchor);
    },
    detach: (detaching) {
      if (detaching) {
        detach(h1);
      }
    },
  );
}

var name = 'world';

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
