import 'dart:html';

import 'package:svelte/runtime.dart';

import 'nested.dart';

Fragment createFragment(List<Object?> instance) {
  return AppFragment();
}

class AppFragment extends Fragment {
  AppFragment() {
    nested0 = Nested(Options(props: <String, Object?>{'answer': 42}));
    nested1 = Nested(Options());
  }

  late Nested nested0;

  late Text t;

  late Nested nested1;

  bool current = false;

  @override
  void create() {
    createComponent(nested0);
    t = space();
    createComponent(nested1);
  }

  @override
  void mount(Element target, Node? anchor) {
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
