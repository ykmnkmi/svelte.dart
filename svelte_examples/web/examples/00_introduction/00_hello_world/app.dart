import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart' show Element, Node;

Fragment createFragment(List<Object?> instance) {
  late Element h1;

  return Fragment(
    create: () {
      h1 = element('h1');
      setText(h1, 'Hello $name!');
    },
    mount: (Element target, Node? anchor) {
      insert(target, h1, anchor);
    },
    detach: (bool detaching) {
      if (detaching) {
        detach(h1);
      }
    },
  );
}

var name = 'world';

final class App extends Component {
  App({
    super.target,
    super.anchor,
    super.props,
    super.hydrate,
    super.intro,
  }) : super(createFragment: createFragment);
}
