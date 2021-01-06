// will be generated
library app;

import 'dart:html';

import 'package:piko/runtime.dart';

class App extends Component<App> {
  App() {
    count = 0;
  }

  int count;

  void handleClick() {
    count += 1;
  }

  @override
  Fragment<App> createFragment() {
    return AppFragment(this);
  }
}

class AppFragment extends Fragment<App> {
  AppFragment(this.context) {
    t3Value = context.count == 1 ? 'time' : 'times';
    mounted = false;
  }

  @override
  final App context;

  Element button;

  Node t0, t1, t2, t3;

  String t3Value;

  bool mounted;

  void Function() dispose;

  @override
  void create() {
    button = element('button');
    t0 = text('Clicked ');
    t1 = text('${context.count}');
    t2 = space();
    t3 = text(t3Value);
  }

  @override
  void mount(Element target) {
    insert(target, button);
    append(button, t0);
    append(button, t1);
    append(button, t2);
    append(button, t3);

    if (!mounted) {
      mounted = true;
      dispose = listen(button, 'click', (event) {
        context.handleClick();
        update('count');
      });
    }
  }

  @override
  void update([String aspect]) {
    if (aspect == null || aspect == 'count') {
      setData(t1, '${context.count}');

      if (t3Value != (t3Value = context.count == 1 ? 'time' : 'times')) {
        setData(t3, t3Value);
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
