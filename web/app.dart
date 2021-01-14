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
    // return <button (click)="handleClick()">Clicked {{ count }} {{ count === 1 ? 'time' : 'times' }}</button>;
    return fragment = AppFragment(this);
  }
}

// will be generated

class AppFragment extends Fragment<App> {
  AppFragment(App context)
      : t3Value = context.count == 1 ? 'time' : 'times',
        mounted = false,
        super(context);

  Element button;

  Node t0;

  Node t1;

  Node t2;

  Node t3;

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
        scheduler.makeDirty(this, 'count');
      });
    }
  }

  @override
  void update([Set<String> aspects = const {}]) {
    if (aspects.isEmpty || aspects.contains('count')) {
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
