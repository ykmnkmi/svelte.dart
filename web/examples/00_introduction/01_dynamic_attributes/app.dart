import 'dart:html';

import 'package:svelte/runtime.dart';

var src = '/tutorial/image.gif';
var name = 'Rick Astley';

Fragment createFragment(List<Object?> instance) {
  late Element img;

  return Fragment(
    create: () {
      img = element('img');
      setAttribute(img, 'src', src);
      setAttribute(img, 'alt', '$name dancing');
    },
    mount: (target, anchor) {
      insert(target, img, anchor);
    },
    detach: (detaching) {
      if (detaching) {
        remove(img);
      }
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
