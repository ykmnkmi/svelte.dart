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

  late Text t;

  @override
  void create() {
    t = text('hello world!');
  }

  @override
  void mount(Node target, [Node? anchor]) {
    insert(target, t, anchor);
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(t);
    }
  }
}
