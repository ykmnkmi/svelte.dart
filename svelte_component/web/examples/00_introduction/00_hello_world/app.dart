import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart' show Element, Node;

final class AppFragment extends Fragment {
  AppFragment(List<Object?> instance);

  late Element h1;

  @override
  void create(List<Object?> instance) {
    h1 = element('h1');
    setText(h1, 'Hello $name!');
  }

  @override
  void mount(List<Object?> instance, Element target, Node? anchor) {
    insert(target, h1, anchor);
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(h1);
    }
  }
}

var name = 'world';

final class App extends Component {
  App({
    super.target,
    super.anchor,
    super.inputs,
    super.hydrate,
    super.intro,
  }) : super(createFragment: AppFragment.new);
}
