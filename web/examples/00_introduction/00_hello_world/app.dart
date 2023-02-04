import 'dart:html';

import 'package:svelte/runtime.dart';

var name = 'world';

Fragment createFragment(List<Object?> instance) {
  return AppFragment();
}

class AppFragment extends Fragment {
  late Element h1;

  @override
  void create() {
    h1 = element('h1');
    setText(h1, 'Hello $name!');
  }

  @override
  void mount(Element target, Node? anchor) {
    insert(target, h1, anchor);
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(h1);
    }
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
