import 'dart:html';

import 'package:svelte/runtime.dart';

Fragment createFragment(List<Object?>? values) {
  return NestedFragment();
}

class NestedFragment extends Fragment {
  late ParagraphElement p;

  @override
  void create() {
    p = element<ParagraphElement>('p');
    setText(p, "...don't affect this element");
  }

  @override
  void mount(target, anchor) {
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
    );
  }
}
