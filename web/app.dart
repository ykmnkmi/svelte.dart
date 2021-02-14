// will be generated
library app;

import 'dart:html';

import 'package:piko/runtime.dart';

class App extends Component<App> {
  App() : count = 0;

  int count;

  void handleClick() {
    count += 1;
  }

  @override
  Fragment<App> render([Scheduler? scheduler]) {
    return AppFragment(this, scheduler ?? Scheduler());
  }
}

class AppFragment extends Fragment<App> {
  AppFragment(App context, Scheduler scheduler)
      : text3Value = context.count == 1 ? 'time' : 'times',
        mounted = false,
        super(context, scheduler);

  late Element button;

  late Text text0;

  late Text text1;

  late Text text2;

  late Text text3;

  late String text3Value;

  late bool mounted;

  late void Function() dispose;

  @override
  void create() {
    button = element('button');
    text0 = text('Clicked ');
    text1 = text('${context.count}');
    text2 = space();
    text3 = text(text3Value);
  }

  @override
  void mount(Node target) {
    insert(target, button);
    append(button, text0);
    append(button, text1);
    append(button, text2);
    append(button, text3);

    if (!mounted) {
      mounted = true;
      dispose = listen(button, 'click', (event) {
        context.handleClick();
        scheduler.makeDirty(this);
      });
    }
  }

  @override
  void update([Set<String> aspects = const <String>{}]) {
    if (aspects.isEmpty || aspects.contains('count')) {
      setData(text1, '${context.count}');

      if (text3Value != (text3Value = context.count == 1 ? 'time' : 'times')) {
        setData(text3, text3Value);
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
