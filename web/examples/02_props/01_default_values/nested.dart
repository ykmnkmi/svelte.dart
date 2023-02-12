import 'dart:html';

import 'package:svelte/runtime.dart';

Fragment createFragment(List<Object?> instance) {
  return NestedFragment(NestedInstance(instance));
}

class NestedFragment extends Fragment {
  NestedFragment(this.instance);

  final NestedInstance instance;

  late Element p;

  late Text t0, t1;

  @override
  void create() {
    p = element('p');
    t0 = text('The answer is ');
    t1 = text('${instance.answer}');
  }

  @override
  void mount(Element target, Node? anchor) {
    insert(target, p, anchor);
    append(p, t0);
    append(p, t1);
  }

  @override
  void update(List<int> dirty) {
    if (dirty[0] & 1 != 0) {
      setData(t1, '${instance.answer}');
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
  Props props,
  Invalidate invalidate,
) {
  var answer = props.containsKey('props') ? props['answer'] : 'a mystery';

  setComponentSet(component, (Props props) {
    if (props.containsKey('answer')) {
      invalidate(0, answer = props['answer']);
    }
  });

  return <Object?>[answer];
}

class NestedInstance {
  NestedInstance(List<Object?> instance) : _instance = instance;

  final List<Object?> _instance;

  Object? get answer {
    return _instance[0];
  }
}

class Nested extends Component {
  Nested(Options options) {
    init<Nested>(
      component: this,
      options: options,
      createInstance: createInstance,
      createFragment: createFragment,
      props: <String, int>{
        'answer': 0,
      },
    );
  }
}
