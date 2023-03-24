import 'dart:html';

import 'package:svelte/runtime.dart';

var name = 'world';

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
        remove(h1);
      }
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
