import 'dart:html';

import 'package:svelte/runtime.dart';

Fragment createFragment(List<Object?> instance) {
  return AppFragment(AppInstance(instance));
}

class AppFragment extends Fragment {
  AppFragment(this.instance);

  final AppInstance instance;

  late Element button;

  late Text t1, t2, t3, t4;

  late String t4_;

  bool mounted = false;

  late void Function() dispose;

  @override
  void create() {
    button = element('button');
    t1 = text('Clicked ');
    t2 = text('${instance.count}');
    t3 = space();
    t4 = text(t4_ = instance.count == 1 ? 'time' : 'times');
  }

  @override
  void mount(Element target, Node? anchor) {
    insert(target, button, anchor);
    append(button, t1);
    append(button, t2);
    append(button, t3);
    append(button, t4);

    if (!mounted) {
      dispose = listen(button, 'click', listener(instance.handleClick));
      mounted = true;
    }
  }

  @override
  void update(List<int> dirty) {
    if (dirty[0] & 1 != 0) {
      setData(t2, '${instance.count}');

      if (t4_ != (t4_ = instance.count == 1 ? 'time' : 'times')) {
        setData(t4, t4_);
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

class AppInstance {
  AppInstance(List<Object?> instance) : _instance = instance;

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
    init<App>(
      component: this,
      options: options,
      createInstance: createInstance,
      createFragment: createFragment,
      props: <String, int>{},
    );
  }
}
