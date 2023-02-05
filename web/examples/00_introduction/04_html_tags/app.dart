import 'dart:html';

import 'package:svelte/runtime.dart';

Fragment createFragment(List<Object?> instance) {
  return AppFragment(AppInstance(instance));
}

class AppFragment extends Fragment {
  AppFragment(this.instance);

  final AppInstance instance;

  late Element p;

  @override
  void create() {
    p = element('p');
  }

  @override
  void mount(Element target, Node? anchor) {
    insert(target, p, anchor);
    setInnerHtml(p, instance.string);
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(p);
    }
  }
}

List<Object?> createInstance(
  App component,
  Props props,
  Invalidate invalidate,
) {
  var string = "here's some <strong>HTML!!!</strong>";
  return <Object?>[string];
}

class AppInstance {
  AppInstance(List<Object?> instance) : _instance = instance;

  final List<Object?> _instance;

  String get string {
    return unsafeCast(_instance[0]);
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
