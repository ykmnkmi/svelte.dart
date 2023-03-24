import 'dart:html';

import 'package:svelte/runtime.dart';

Fragment createFragment(List<Object?> instance) {
  var context = AppContext(instance);

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
      t1 = text('${context.count}');
      t2 = space();
      p0 = element('p');
      t3 = text('${context.count}');
      t4 = text(' * 2 = ');
      t5 = text('${context.doubled}');
      t6 = space();
      p1 = element('p');
      t7 = text('${context.doubled}');
      t8 = text(' * 2 = ');
      t9 = text('${context.quadrupled}');
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
        dispose = listen(button, 'click', listener(context.handleClick));
        mounted = true;
      }
    },
    update: (dirty) {
      if (dirty[0] & 1 != 0) {
        setData(t1, '${context.count}');
        setData(t3, '${context.count}');
      }

      if (dirty[0] & 2 != 0) {
        setData(t5, '${context.doubled}');
        setData(t7, '${context.doubled}');
      }

      if (dirty[0] & 4 != 0) {
        setData(t9, '${context.quadrupled}');
      }
    },
    detach: (detaching) {
      if (detaching) {
        remove(button);
        remove(t2);
        remove(p0);
        remove(t6);
        remove(p1);
      }

      mounted = false;
      dispose();
    },
  );
}

List<Object?> createInstance(
  Component self,
  Props props,
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
      if (dirty[0] & 1 != 0) {
        invalidate(1, doubled = count * 2);
      }

      if (dirty[0] & 2 != 0) {
        invalidate(2, quadrupled = doubled * 2);
      }
    };
  });

  return <Object?>[count, null, null, handleClick];
}

class AppContext {
  AppContext(List<Object?> instance) : _instance = instance;

  final List<Object?> _instance;

  int get count {
    return unsafeCast(_instance[0]);
  }

  int get doubled {
    return unsafeCast(_instance[1]);
  }

  int get quadrupled {
    return unsafeCast(_instance[2]);
  }

  void Function() get handleClick {
    return unsafeCast(_instance[3]);
  }
}

class App extends Component {
  App(Options options) {
    init(
      component: this,
      options: options,
      createInstance: createInstance,
      createFragment: createFragment,
      props: <String, int>{},
    );
  }
}
