import 'dart:html';

import 'package:svelte/runtime.dart';

Fragment createFragment(List<Object?> instance) {
  return AppFragment(instance);
}

class AppFragment extends Fragment {
  AppFragment(this.instance);

  final List<Object?> instance;

  late ButtonElement button;

  late Text t0, t1, t2, t3;

  late String t3value;

  bool mounted = false;

  late void Function() dispose;

  @override
  void create() {
    button = element<ButtonElement>('button');
    t0 = text('Clicked ');
    t1 = text('${instance[0]}');
    t2 = space();
    t3 = text(t3value = instance[0] == 1 ? 'time' : 'times');
  }

  @override
  void mount(Element target, Node? anchor) {
    insert(target, button, anchor);
    append(button, t0);
    append(button, t1);
    append(button, t2);
    append(button, t3);

    if (!mounted) {
      var calback = instance[1] as void Function();
      dispose = listen(button, 'click', listener(calback));
      mounted = true;
    }
  }

  @override
  void update(List<Object?> instance, List<int> dirty) {
    if (dirty[0] & 1 != 0) {
      setData(t1, '${instance[0]}');

      if (t3value != (t3value = instance[0] == 1 ? 'time' : 'times')) {
        setData(t3, t3value);
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
