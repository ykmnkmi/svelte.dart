import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart' show Element, Node;

final class AppFragment extends Fragment {
  AppFragment(List<Object?> instance);

  late Element img;

  @override
  void create(List<Object?> instance) {
    img = element('img');
    setAttribute(img, 'src', src);
    setAttribute(img, 'alt', '$name dancing');
  }

  @override
  void mount(List<Object?> instance, Element target, Node? anchor) {
    insert(target, img, anchor);
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(img);
    }
  }
}

var src = '/tutorial/image.gif';
var name = 'Rick Astley';

final class App extends Component {
  App({
    super.target,
    super.anchor,
    super.inputs,
    super.hydrate,
    super.intro,
  }) : super(createFragment: AppFragment.new);
}
