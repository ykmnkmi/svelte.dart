import 'dart:html';

import 'package:svelte/runtime.dart';

Fragment createFragment(List<Object?> instance) {
  return AppFragment(instance);
}

class AppFragment extends Fragment {
  AppFragment(this.instance);

  final List<Object?> instance;

  late ButtonElement button;

  late Text t1, t2, t3, t4;

  late String t4value;

  bool mounted = false;

  late void Function() dispose;

  @override
  void create() {
    button = element<ButtonElement>('button');
    t1 = text('Clicked ');
    t2 = text('${instance[0]}');
    t3 = space();
    t4 = text(t4value = instance[0] == 1 ? 'time' : 'times');
  }

  @override
  void mount(Element target, Node? anchor) {
    insert(target, button, anchor);
    append(button, t1);
    append(button, t2);
    append(button, t3);
    append(button, t4);

    if (!mounted) {
      var calback = instance[1] as void Function();
      dispose = listen(button, 'click', listener(calback));
      mounted = true;
    }
  }

  @override
  void update(List<Object?> instance, List<int> dirty) {
    if (dirty[0] & 1 != 0) {
      setData(t2, '${instance[0]}');

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

List<Object?> createInstance(
  App component,
  Props props,
  Invalidate invalidate,
) {
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
      props: <String, int>{},
    );
  }
}
