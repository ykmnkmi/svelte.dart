import 'dart:html';

import 'package:svelte/runtime.dart';

import 'nested.dart';

Fragment createFragment(List<Object?> instance) {
  return AppFragment();
}

class AppFragment extends Fragment {
  AppFragment() {
    nested = Nested(Options(props: <String, Object?>{'answer': 42}));
  }

  late Nested nested;

  bool current = false;

  @override
  void create() {
    createComponent(nested);
  }

  @override
  void mount(Element target, Node? anchor) {
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

class App extends Component {
  App(Options options) {
    init<App>(
      component: this,
      options: options,
      createFragment: createFragment,
      props: <String, int>{},
    );
  }
}
