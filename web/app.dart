library app;

import 'dart:html';

import 'package:piko/piko.dart';

class App extends Component<App> {
  App({this.count = 0});

  int count;

  void handleClick() {
    count += 1;
  }

  @override
  Fragment<App> render(RenderTree tree) {
    return AppFragment(this, tree);
  }
}

class AppFragment extends Fragment<App> {
  AppFragment(App context, RenderTree tree)
      : mounted = false,
        super(context, tree);

  Element? button1;

  Text? t1;

  Text? t2;

  Text? t3;

  Text? t4;

  String? t4value;

  bool mounted;

  VoidCallback? dispose;

  @override
  void create() {
    button1 = element('button');
    t1 = text('Clicked ');
    t2 = text('${context.count}');
    t3 = text(' ');
    t4 = text('${context.count == 1 ? 'time' : 'times'}');
  }

  @override
  void mount(Element target, [Node? anchor]) {
    insert(target, button1!, anchor);
    append(button1!, t1!);
    append(button1!, t2!);
    append(button1!, t3!);
    append(button1!, t4!);

    if (!mounted) {
      dispose = listen(button1!, 'click', (Event event) {
        context.handleClick();
        markDirty('count');
      });
    }
  }

  @override
  void update(Set<String> aspects) {
    if (aspects.contains('count')) {
      setData(t2!, '${context.count}');

      if (t4value != (t4value = context.count == 1 ? 'time' : 'times')) {
        setData(t4!, t4value!);
      }
    }
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(button1!);
    }

    mounted = false;
    dispose!();
  }
}
