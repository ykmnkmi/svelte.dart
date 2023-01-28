import 'dart:html';

import 'package:svelte/runtime.dart';

var name = 'world';

Fragment createFragment(List<Object?>? values) {
  return NestedFragment();
}

class NestedFragment extends Fragment {
  late ParagraphElement p;

  @override
  void create() {
    p = element('p');
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
    init(this, options, null, createFragment);
  }
}
