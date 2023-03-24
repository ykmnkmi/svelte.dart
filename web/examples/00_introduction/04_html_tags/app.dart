import 'dart:html';

import 'package:svelte/runtime.dart';

Fragment createFragment(List<Object?> instance) {
  var context = AppContext(instance);

  late Element p;

  return Fragment(
    create: () {
      p = element('p');
    },
    mount: (target, anchor) {
      insert(target, p, anchor);
      setInnerHtml(p, context.string);
    },
    detach: (detaching) {
      if (detaching) {
        remove(p);
      }
    },
  );
}

List<Object?> createInstance(
  Component self,
  Props props,
  Invalidate invalidate,
) {
  var string = "here's some <strong>HTML!!!</strong>";
  return <Object?>[string];
}

class AppContext {
  AppContext(List<Object?> instance) : _instance = instance;

  final List<Object?> _instance;

  String get string {
    return unsafeCast(_instance[0]);
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
