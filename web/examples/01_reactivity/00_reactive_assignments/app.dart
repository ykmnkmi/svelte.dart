import 'dart:html';

import 'package:svelte/runtime.dart';

Fragment createFragment(List<Object?> instance) {
  var context = AppContext(instance);

  late Element button;
  late Text t1, t2, t3, t4;

  late String t4value;

  var mounted = false;

  late void Function() dispose;

  return Fragment(
    create: () {
      button = element('button');
      t1 = text('Clicked ');
      t2 = text('${context.count}');
      t3 = space();
      t4 = text(t4value = context.count == 1 ? 'time' : 'times');
    },
    mount: (target, anchor) {
      insert(target, button, anchor);
      append(button, t1);
      append(button, t2);
      append(button, t3);
      append(button, t4);

      if (!mounted) {
        dispose = listen(button, 'click', listener(context.handleClick));
        mounted = true;
      }
    },
    update: (dirty) {
      if (dirty[0] & 1 != 0) {
        setData(t2, '${context.count}');

        if (t4value != (t4value = context.count == 1 ? 'time' : 'times')) {
          setData(t4, t4value);
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
