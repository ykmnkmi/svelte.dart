import 'dart:html';

import 'package:svelte_runtime/svelte_runtime.dart';

extension on List<Object?> {
  int get _count {
    return this[0] as int;
  }

  void Function() get _handleClick {
    return this[1] as void Function();
  }
}

Fragment createFragment(List<Object?> instance) {
  late Element button;
  late Text t0, t1, t2, t3;

  late String t3value;

  var mounted = false;

  late void Function() dispose;

  return Fragment(
    create: () {
      button = element('button');
      t0 = text('Clicked ');
      t1 = text('${instance._count}');
      t2 = space();
      t3 = text(t3value = instance._count == 1 ? 'time' : 'times');
    },
    mount: (Element target, Node? anchor) {
      insert(target, button, anchor);
      append(button, t0);
      append(button, t1);
      append(button, t2);
      append(button, t3);

      if (!mounted) {
        dispose = listen(button, 'click', listener(instance._handleClick));
        mounted = true;
      }
    },
    update: (List<Object?> context, List<int> dirty) {
      if (dirty[0] & 1 != 0) {
        setData(t1, '${context._count}');

        if (t3value != (t3value = context._count == 1 ? 'time' : 'times')) {
          setData(t3, t3value);
        }
      }
    },
    detach: (bool detaching) {
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

  setComponentUpdate(self, (List<int> dirty) {
    return () {
      if (dirty[0] & 1 != 0) {
        $:
        if (count >= 10) {
          window.alert('count is dangerously high!');
          invalidate(0, count = 9);
        }
      }
    };
  });

  return <Object?>[count, handleClick];
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
