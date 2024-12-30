import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart' show Element, Node, Text;

extension on List<Object?> {
  Object? get _answer {
    return this[0];
  }
}

final class NestedFragment extends Fragment {
  NestedFragment(List<Object?> instance);

  late Element p;
  late Text t0;
  late Text t1;

  @override
  void create(List<Object?> instance) {
    p = element('p');
    t0 = text('The answer is ');
    t1 = text('${instance._answer}');
  }

  @override
  void mount(List<Object?> instance, Element target, Node? anchor) {
    insert(target, p, anchor);
    append(p, t0);
    append(p, t1);
  }

  @override
  void update(List<Object?> context, int dirty) {
    if (dirty & 1 != 0) {
      setData(t1, '${context._answer}');
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
  Component self,
  Map<String, Object?> inputs,
  Invalidate invalidate,
) {
  Object? answer = inputs['answer'];

  setComponentSetter(self, (Map<String, Object?> inputs) {
    if (inputs.containsKey('answer')) {
      invalidate(0, answer = inputs['answer']);
    }
  });

  return <Object?>[answer];
}

final class Nested extends Component {
  Nested({
    super.target,
    super.anchor,
    super.inputs,
    super.hydrate,
    super.intro,
  }) : super(
            createInstance: createInstance,
            createFragment: NestedFragment.new,
            properties: const <String, int>{'answer': 0});
}
