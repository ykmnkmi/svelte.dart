import 'dart:html';

import 'package:svelte/runtime.dart';

Fragment createFragment(List<Object?> instance) {
  return AppFragment(instance);
}

class AppFragment extends Fragment {
  AppFragment(this.instance);

  final List<Object?> instance;

  late ParagraphElement p;

  @override
  void create() {
    p = element<ParagraphElement>('p');
  }

  @override
  void mount(Element target, Node? anchor) {
    insert(target, p, anchor);
    setInnerHtml(p, instance[0] as String);
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
