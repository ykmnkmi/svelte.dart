import 'dart:html';

import 'package:svelte_runtime/svelte_runtime.dart';

Fragment createFragment(List<Object?> instance) {
  late Element img;

  return Fragment(
    create: () {
      img = element('img');
      setAttribute(img, 'src', src);
      setAttribute(img, 'alt', '$name dancing');
    },
    mount: (Element target, Node? anchor) {
      insert(target, img, anchor);
    },
    detach: (bool detaching) {
      if (detaching) {
        detach(img);
      }
    },
  );
}

var src = '/tutorial/image.gif';
var name = 'Rick Astley';

final class App extends Component {
  App({
    super.target,
    super.anchor,
    super.props,
    super.hydrate,
    super.intro,
  }) : super(createFragment: createFragment);
}
