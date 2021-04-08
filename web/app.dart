// will be generated
library app;

import 'dart:html';

import 'package:piko/internal.dart';

class App extends Component<App> {
  @override
  Fragment<App> render([Scheduler? scheduler]) {
    return AppFragment(this, scheduler ?? Scheduler());
  }
}

class AppFragment extends Fragment<App> {
  AppFragment(App context, Scheduler scheduler) : super(context, scheduler);

  late Element p;

  @override
  void create() {
    p = element('p');
    p.text = 'hello world!';
  }

  @override
  void mount(Node target, [Node? anchor]) {
    insert(target, p, anchor);
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(p);
    }
  }
}
