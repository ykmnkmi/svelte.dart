import 'dart:html';

import 'package:svelte_runtime/svelte_runtime.dart';

extension on List<Object?> {
  Object? get _answer {
    return this[0];
  }
}

Fragment createFragment(List<Object?> instance) {
  late Element p;
  late Text t0, t1;

  return Fragment(
    create: () {
      p = element('p');
      t0 = text('The answer is ');
      t1 = text('${instance._answer}');
    },
    mount: (Element target, Node? anchor) {
      insert(target, p, anchor);
      append(p, t0);
      append(p, t1);
    },
    update: (List<Object?> instance, List<int> dirty) {
      if (dirty[0] & 1 != 0) {
        setData(t1, '${instance._answer}');
      }
    },
    detach: (bool detaching) {
      if (detaching) {
        detach(p);
      }
    },
  );
}

List<Object?> createInstance(
  Component self,
  Map<String, Object?> props,
  Invalidate invalidate,
) {
  var answer = props.containsKey('answer') ? props['answer'] : 'a mystery';

  setComponentSet(self, (Map<String, Object?> props) {
    if (props.containsKey('answer')) {
      invalidate(0, answer = props['answer']);
    }
  });

  return <Object?>[answer];
}

final class Nested extends Component {
  Nested({
    super.target,
    super.anchor,
    super.props,
    super.hydrate,
    super.intro,
  }) : super(createInstance: createInstance, createFragment: createFragment);
}
