import 'dart:html';

import 'package:svelte_web_runtime/svelte_web_runtime.dart';

Fragment createFragment(List<Object?> instance) {
  late Element p;
  late Text t0, t1;

  return Fragment(
    create: () {
      p = element('p');
      t0 = text('The answer is ');
      t1 = text('${instance._answer}');
    },
    mount: (target, anchor) {
      insert(target, p, anchor);
      append(p, t0);
      append(p, t1);
    },
    update: (context, dirty) {
      if (dirty[0] & 1 != 0) {
        setData(t1, '${context._answer}');
      }
    },
    detach: (detaching) {
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
  var answer = props['answer'];

  setComponentSet(self, (props) {
    if (props.containsKey('answer')) {
      invalidate(0, answer = props['answer']);
    }
  });

  return <Object?>[answer];
}

extension on List<Object?> {
  Object? get _answer {
    return this[0];
  }
}

class Nested extends Component {
  Nested({
    Element? target,
    Node? anchor,
    Map<String, Object?>? props,
    bool hydrate = false,
    bool intro = false,
  }) {
    init(
      component: this,
      options: (
        target: target,
        anchor: anchor,
        props: props,
        hydrate: hydrate,
        intro: intro,
      ),
      createInstance: createInstance,
      createFragment: createFragment,
      props: <String, int>{'answer': 0},
    );
  }
}
