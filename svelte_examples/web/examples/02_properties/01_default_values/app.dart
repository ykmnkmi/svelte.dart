import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart' show Element, Node, Text;

import 'nested.dart';

final class AppFragment extends Fragment {
  AppFragment(List<Object?> instance) {
    nested0 = Nested(inputs: <String, Object?>{'answer': '42'});
    nested1 = Nested();
  }

  late Nested nested0;
  late Text t;
  late Nested nested1;

  bool current = false;

  @override
  void create(List<Object?> instance) {
    createComponent(nested0);
    t = space();
    createComponent(nested1);
  }

  @override
  void mount(List<Object?> instance, Element target, Node? anchor) {
    mountComponent(nested0, target, anchor);
    insert(target, t, anchor);
    mountComponent(nested1, target, anchor);
    current = true;
  }

  @override
  void intro(bool local) {
    if (current) {
      return;
    }

    transitionInComponent(nested0, local);
    transitionInComponent(nested1, local);
    current = true;
  }

  @override
  void outro(bool local) {
    transitionOutComponent(nested0, local);
    transitionOutComponent(nested1, local);
    current = false;
  }

  @override
  void detach(bool detaching) {
    destroyComponent(nested0, detaching);

    if (detaching) {
      remove(t);
    }

    destroyComponent(nested1, detaching);
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
