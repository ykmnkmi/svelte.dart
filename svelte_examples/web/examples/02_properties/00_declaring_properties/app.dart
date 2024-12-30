import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart' show Element, Node;

import 'nested.dart';

final class AppFragment extends Fragment {
  AppFragment(List<Object?> instance) {
    nested = Nested(inputs: <String, Object?>{'answer': 42});
  }

  late Nested nested;

  bool current = false;

  @override
  void create(List<Object?> instance) {
    createComponent(nested);
  }

  @override
  void mount(List<Object?> instance, Element target, Node? anchor) {
    mountComponent(nested, target, anchor);
    current = true;
  }

  @override
  void intro(bool local) {
    if (current) {
      return;
    }

    transitionInComponent(nested, local);
    current = true;
  }

  @override
  void outro(bool local) {
    transitionOutComponent(nested, local);
    current = false;
  }

  @override
  void detach(bool detaching) {
    destroyComponent(nested, detaching);
  }
}

final class App extends Component {
  App({
    super.target,
    super.anchor,
    super.inputs,
    super.hydrate,
    super.intro,
  }) : super(createFragment: AppFragment.new);
}
