import 'dart:html';

import 'package:svelte/runtime.dart';

Fragment createFragment(Instance instance) {
  return AppFragment(instance);
}

class AppFragment extends Fragment {
  AppFragment(this.instance);

  final Instance instance;

  late ParagraphElement p;

  @override
  void create() {
    p = element('p');
  }

  @override
  void mount(target, anchor) {
    insert(target, p, anchor);
    setInnerHtml(p, unsafeCast(instance[0]));
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(p);
    }
  }
}

Instance createInstance(App component, Invalidate invalidate) {
  var string = "here's some <strong>HTML!!!</strong>";
  return <Object?>[string];
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
