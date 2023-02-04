import 'dart:html';

import 'package:svelte/runtime.dart';

Fragment createFragment(List<Object?> instance) {
  return NestedFragment();
}

class NestedFragment extends Fragment {
  late Element p;

  @override
  void create() {
    p = element('p');
    setText(p, "...don't affect this element");
  }

  @override
  void mount(Element target, Node? anchor) {
    insert(target, p, anchor);
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(p);
    }
  }
}

class Nested extends Component {
  Nested(Options options) {
    init<Nested>(
      component: this,
      options: options,
      createFragment: createFragment,
      props: <String, int>{},
    );
  }
}
