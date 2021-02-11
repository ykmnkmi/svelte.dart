// @dart=2.10

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
  Fragment<App> render() {
    return AppFragment(this);
  }
}

class AppFragment extends Fragment<App> {
  AppFragment(App context)
      : text3Value = context.count == 1 ? 'time' : 'times',
        mounted = false,
        super(context);

  Element button;

  Node text0;

  Node text1;

  Node text2;

  Node text3;

  String text3Value;

  bool mounted;

  void Function() dispose;

  @override
  void create() {
    button = element('button');
    text0 = text('Clicked ');
    text1 = text('${context.count}');
    text2 = space();
    text3 = text(text3Value);
  }

  @override
  void mount(Element target) {
    insert(target, button);
    append(button, text0);
    append(button, text1);
    append(button, text2);
    append(button, text3);

    if (!mounted) {
      mounted = true;
      dispose = listen(button, 'click', (event) {
        context.handleClick();
        scheduler.makeDirty(this, 'count');
      });
    }
  }

  @override
  void update([Set<String> aspects = const {}]) {
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
