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
  App(Options options) {
    init(
      component: this,
      options: options,
      createFragment: createFragment,
      props: <String, int>{},
    );
  }
}
