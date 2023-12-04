import 'dart:html';

import 'package:svelte_runtime/svelte_runtime.dart';

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
    mount: (Element target, Node? anchor) {
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
    update: (List<Object?> context, List<int> dirty) {
      if (dirty[0] & 1 != 0) {
        setData(t1, '${context._count}');
        setData(t3, '${context._count}');
      }

      if (dirty[0] & 2 != 0) {
        setData(t5, '${context._doubled}');
        setData(t7, '${context._doubled}');
      }

      if (dirty[0] & 4 != 0) {
        setData(t9, '${context._quadrupled}');
      }
    },
    detach: (bool detaching) {
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
  late int quadrupled; // ignore: unused_local_variable

  void handleClick() {
    invalidate(0, count += 1);
  }

  setComponentUpdate(self, (List<int> dirty) {
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

final class App extends Component {
  App({
    super.target,
    super.anchor,
    super.props,
    super.hydrate,
    super.intro,
  }) : super(createInstance: createInstance, createFragment: createFragment);
}
