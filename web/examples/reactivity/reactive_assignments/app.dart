import 'dart:html';

import 'package:svelte/runtime.dart';

Fragment createFragment(Instance instance) {
  return AppFragment(instance);
}

class AppFragment extends Fragment {
  AppFragment(this.instance);

  final Instance instance;

  late ButtonElement button;

  late Text t1, t2, t3, t4;

  late String t4value;

  bool mounted = false;

  late VoidCallback dispose;

  @override
  void create() {
    button = element('button');
    t1 = text('Clicked ');
    t2 = text('${instance[0]}');
    t3 = space();
    t4 = text(t4value = instance[0] == 1 ? 'time' : 'times');
  }

  @override
  void mount(target, anchor) {
    insert(target, button, anchor);
    append(button, t1);
    append(button, t2);
    append(button, t3);
    append(button, t4);

    if (!mounted) {
      dispose = listen(button, 'click', listener(unsafeCast(instance[1])));
      mounted = true;
    }
  }

  @override
  void update(Instance instance, int dirty) {
    if (dirty & 1 == 1) {
      setData(t1, '${instance[0]}');

      if (t4value != (t4value = instance[0] == 1 ? 'time' : 'times')) {
        setData(t4, t4value);
      }
    }
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(button);
    }

    mounted = false;
    dispose();
  }
}

Instance createInstance(App component, Invalidate invalidate) {
  var count = 0;

  void handleClick() {
    invalidate(0, count += 1);
  }

  return <Object?>[count, handleClick];
}

class App extends Component {
  App(Options options) {
    init<App>(
      component: this,
      options: options,
      createInstance: createInstance,
      createFragment: createFragment,
    );
  }
}
