import 'dart:html';

import 'package:svelte/runtime.dart';

var name = 'world';

Fragment createFragment(List<Object?>? values) {
  return AppFragment();
}

class AppFragment extends Fragment {
  late HeadingElement h1;

  @override
  void create() {
    h1 = element('h1');
    setText(h1, 'Hello $name!');
  }

  @override
  void mount(target, anchor) {
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
    init(this, options, null, createFragment);
  }
}
