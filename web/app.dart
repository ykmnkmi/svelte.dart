// will be generated

library app;

import 'dart:html';

import 'package:piko/runtime.dart';

class App extends Component<App> {
  App({this.name = 'world'});

  final String name;

  @override
  Fragment<App> render([Scheduler? scheduler]) {
    return AppFragment(this, scheduler ?? Scheduler());
  }
}

class AppFragment extends Fragment<App> {
  AppFragment(App context, Scheduler scheduler) : super(context, scheduler);

  late Element p1;

  late Text t1;

  late Text t2;

  late Text t3;

  @override
  void create() {
    p1 = element('p');
    t1 = text('hello ');
    t2 = text(context.name);
    t3 = text('!');
  }

  @override
  void mount(Node target, [Node? anchor]) {
    insert(target, p1);
    insert(p1, t1);
    insert(p1, t2);
    insert(p1, t3);
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(p1);
    }
  }
}
