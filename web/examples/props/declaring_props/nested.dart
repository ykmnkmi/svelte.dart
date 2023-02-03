import 'dart:html';

import 'package:svelte/runtime.dart';

Fragment createFragment(List<Object?> instance) {
  return NestedFragment(instance);
}

class NestedFragment extends Fragment {
  NestedFragment(this.instance);

  final List<Object?> instance;

  late ParagraphElement p;

  late Text t0, t1;

  @override
  void create() {
    p = element<ParagraphElement>('p');
    t0 = text('The answer is ');
    t1 = text('${instance[0] ?? ''}');
  }

  @override
  void mount(Element target, Node? anchor) {
    insert(target, p, anchor);
    append(p, t0);
    append(p, t1);
  }

  @override
  void update(List<Object?> instance, List<int> dirty) {
    if (dirty[0] & 1 != 0) {
      setData(t1, '${instance[0] ?? ''}');
    }
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(p);
    }
  }
}

List<Object?> createInstance(
  Nested component,
  Map<String, Object?> props,
  Invalidate invalidate,
) {
  int? answer = props['answer'] as int?;

  setComponentSet(component, (Map<String, Object?> props) {
    if (props.containsKey('answer')) {
      invalidate(0, answer = props['answer'] as int?);
    }
  });

  return <Object?>[answer];
}

class Nested extends Component {
  Nested(Options options) {
    init<Nested>(
      component: this,
      options: options,
      createInstance: createInstance,
      createFragment: createFragment,
      props: <String, int>{'answer': 0},
    );
  }
}
