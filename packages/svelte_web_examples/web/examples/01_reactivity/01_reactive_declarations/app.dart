import 'dart:html';

import 'package:svelte_web_runtime/svelte_web_runtime.dart';

Fragment createFragment(List<Object?> instance) {
  late Element button;
  late Text t0, t1, t2;
  late Element p0;
  late Text t3, t4, t5, t6;
  late Element p1;
  late Text t7, t8, t9;

  var mounted = false;

  late void Function() dispose;

  return Fragment(
    create: () {
      button = element('button');
      t0 = text('Count: ');
      t1 = text('${instance._count}');
      t2 = space();
      p0 = element('p');
      t3 = text('${instance._count}');
      t4 = text(' * 2 = ');
      t5 = text('${instance._doubled}');
      t6 = space();
      p1 = element('p');
      t7 = text('${instance._doubled}');
      t8 = text(' * 2 = ');
      t9 = text('${instance._quadrupled}');
    },
    mount: (target, anchor) {
      insert(target, button, anchor);
      append(button, t0);
      append(button, t1);
      insert(target, t2, anchor);
      insert(target, p0, anchor);
      append(p0, t3);
      append(p0, t4);
      append(p0, t5);
      insert(target, t6, anchor);
      insert(target, p1, anchor);
      append(p1, t7);
      append(p1, t8);
      append(p1, t9);

      if (!mounted) {
        dispose = listen(button, 'click', listener(instance._handleClick));
        mounted = true;
      }
    },
    update: (context, dirty) {
      if (dirty & 1 != 0) {
        setData(t1, '${context._count}');
        setData(t3, '${context._count}');
      }

      if (dirty & 2 != 0) {
        setData(t5, '${context._doubled}');
        setData(t7, '${context._doubled}');
      }

      if (dirty & 4 != 0) {
        setData(t9, '${context._quadrupled}');
      }
    },
    detach: (detaching) {
      if (detaching) {
        detach(button);
        detach(t2);
        detach(p0);
        detach(t6);
        detach(p1);
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
  var count = 1;
  late int doubled;
  late int quadrupled;

  void handleClick() {
    invalidate(0, count += 1);
  }

  setComponentUpdate(self, (dirty) {
    return () {
      if (dirty & 1 != 0) {
        invalidate(1, doubled = count * 2);
      }

      if (dirty & 2 != 0) {
        invalidate(2, quadrupled = doubled * 2);
      }
    };
  });

  return <Object?>[count, null, null, handleClick];
}

extension on List<Object?> {
  int get _count {
    return this[0] as int;
  }

  int get _doubled {
    return this[1] as int;
  }

  int get _quadrupled {
    return this[2] as int;
  }

  void Function() get _handleClick {
    return this[3] as void Function();
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
