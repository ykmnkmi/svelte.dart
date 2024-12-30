import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart' show Element, Node;

final class NestedFragment extends Fragment {
  NestedFragment(List<Object?> instance);

  late Element p;

  @override
  void create(List<Object?> instance) {
    p = element('p');
    setText(p, "...don't affect this element");
  }

  @override
  void mount(List<Object?> instance, Element target, Node? anchor) {
    insert(target, p, anchor);
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(p);
    }
  }
}

final class Nested extends Component {
  Nested({
    super.target,
    super.anchor,
    super.inputs,
    super.hydrate,
    super.intro,
  }) : super(createFragment: NestedFragment.new);
}
