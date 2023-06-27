import 'dart:html';

import 'package:svelte_web_runtime/svelte_web_runtime.dart';

Fragment createFragment(List<Object?> instance) {
  late Element button;
  late Text t1, t2, t3, t4;

  late String t4value;

  var mounted = false;

  late void Function() dispose;

  return Fragment(
    create: () {
      button = element('button');
      t1 = text('Clicked ');
      t2 = text('${instance._count}');
      t3 = space();
      t4 = text(t4value = instance._count == 1 ? 'time' : 'times');
    },
    mount: (target, anchor) {
      insert(target, button, anchor);
      append(button, t1);
      append(button, t2);
      append(button, t3);
      append(button, t4);

      if (!mounted) {
        dispose = listen(button, 'click', listener(instance._handleClick));
        mounted = true;
      }
    },
    update: (context, dirty) {
      if (dirty[0] & 1 != 0) {
        setData(t2, '${context._count}');

        if (t4value != (t4value = context._count == 1 ? 'time' : 'times')) {
          setData(t4, t4value);
        }
      }
    },
    detach: (detaching) {
      if (detaching) {
        detach(button);
      }

      mounted = false;
      dispose();
    },
  );
}

List<Object?> createInstance(
  Component self,
  Map<String, Object?> props,
  Invalidate invalidate,
) {
  var count = 0;

  void handleClick() {
    invalidate(0, count += 1);
  }

  return <Object?>[count, handleClick];
}

extension on List<Object?> {
  int get _count {
    return this[0] as int;
  }

  void Function() get _handleClick {
    return this[1] as void Function();
  }
}

class App extends Component {
  App({
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
    );
  }
}
