import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart' show Element, Node;

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
    super.properties,
    super.hydrate,
    super.intro,
  }) : super(createFragment: createFragment);
}
