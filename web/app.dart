// will be generated
library app;

import 'dart:html';

import 'package:piko/internal.dart';

class App extends Component<App> {
  final String name = 'world';

  @override
  Fragment<App> render([Scheduler? scheduler]) {
    return AppFragment(this, scheduler ?? Scheduler());
  }
}

class AppFragment extends Fragment<App> {
  AppFragment(App context, Scheduler scheduler) : super(context, scheduler);

  late Text t1;

  late Text t2;

  late Text t3;

  @override
  void create() {
    t1 = text('hello ');
    t2 = text(context.name);
    t3 = text('!');
  }

  @override
  void mount(Node target, [Node? anchor]) {
    insert(target, t1, anchor);
    insert(target, t2, anchor);
    insert(target, t3, anchor);
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(t1);
      remove(t2);
      remove(t3);
    }
  }
}
