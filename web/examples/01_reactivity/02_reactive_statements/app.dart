import 'dart:html';

import 'package:svelte/runtime.dart';

Fragment createFragment(List<Object?> instance) {
  var context = AppContext(instance);

  late Element button;
  late Text t0, t1, t2, t3;

  late String t3value;

  var mounted = false;

  late void Function() dispose;

  return Fragment(
    create: () {
      button = element('button');
      t0 = text('Clicked ');
      t1 = text('${context.count}');
      t2 = space();
      t3 = text(t3value = context.count == 1 ? 'time' : 'times');
    },
    mount: (target, anchor) {
      insert(target, button, anchor);
      append(button, t0);
      append(button, t1);
      append(button, t2);
      append(button, t3);

      if (!mounted) {
        dispose = listen(button, 'click', listener(context.handleClick));
        mounted = true;
      }
    },
    update: (List<int> dirty) {
      if (dirty[0] & 1 != 0) {
        setData(t1, '${context.count}');

        if (t3value != (t3value = context.count == 1 ? 'time' : 'times')) {
          setData(t3, t3value);
        }
      }
    },
    detach: (detaching) {
      if (detaching) {
        remove(button);
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

  setComponentUpdate(self, (dirty) {
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

class AppContext {
  AppContext(List<Object?> instance) : _instance = instance;

  final List<Object?> _instance;

  int get count {
    return unsafeCast(_instance[0]);
  }

  void Function() get handleClick {
    return unsafeCast(_instance[1]);
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
