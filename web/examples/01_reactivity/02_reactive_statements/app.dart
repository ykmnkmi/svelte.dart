import 'dart:html';

import 'package:svelte/runtime.dart';

Fragment createFragment(List<Object?> instance) {
  return AppFragment(instance);
}

class AppFragment extends Fragment {
  AppFragment(this.instance);

  final List<Object?> instance;

  late Element button;

  late Text t0, t1, t2, t3;

  late String t3_;

  bool mounted = false;

  late void Function() dispose;

  @override
  void create() {
    button = element('button');
    t0 = text('Clicked ');
    t1 = text('${instance[0]}');
    t2 = space();
    t3 = text(t3_ = instance[0] == 1 ? 'time' : 'times');
  }

  @override
  void mount(Element target, Node? anchor) {
    insert(target, button, anchor);
    append(button, t0);
    append(button, t1);
    append(button, t2);
    append(button, t3);

    if (!mounted) {
      dispose = listen(button, 'click', listener(unsafeCast(instance[1])));
      mounted = true;
    }
  }

  @override
  void update(List<Object?> instance, List<int> dirty) {
    if (dirty[0] & 1 != 0) {
      setData(t1, '${instance[0]}');

      if (t3_ != (t3_ = instance[0] == 1 ? 'time' : 'times')) {
        setData(t3, t3_);
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

List<Object?> createInstance(
  App component,
  Props props,
  Invalidate invalidate,
) {
  var count = 0;

  void handleClick() {
    invalidate(0, count += 1);
  }

  setComponentUpdate(component, (List<int> dirty) {
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

class App extends Component {
  App(Options options) {
    init<App>(
      component: this,
      options: options,
      createInstance: createInstance,
      createFragment: createFragment,
      props: <String, int>{},
    );
  }
}
