piko.dart
=========

Web framework for [Dart](https://dart.dev).

Plans:
======
- fragment compiler
  - parser
  - generator
- dartx compiler
  - parser
  - builder
- VS Code extension
  - syntax highlighter
  - language server
- change detection
- ...

Done:
- static html fragemnt parser & compiler
- poor VS Code Dart & HTML syntax highlighter

Current:
- move to Angular AST after null-safety release
- parse { ... expression ... }

=======
from:
```
import 'package:piko/piko.dart';

class App extends Component<App> {
  App() : count = 0;
  
  int count;

  void handleClick() {
		count += 1;
	}

  @override
  Fragment<App> render(RenderTree tree) {
    return <button on:click={ handleClick }>
      Clicked { count } { count == 1 ? 'time' : 'times' }
    </button>;
  }
}
```

to:
```
import 'package:piko/piko.dart';

class App extends Component<App> {
  App() : count = 0;

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

  late Element button1;

  late Text t1;

  late Text t2;

  late Text t3;

  late Text t4;

  late String t4value;

  bool mounted;

  late Function dispose;

  @override
  void create() {
    button1 = element('button');
    t1 = text('Clicked ');
    t2 = text('${context.count}');
    t3 = text(' ');
    t4 = text(t4value = '${context.count == 1 ? 'time' : 'times'}');
  }

  @override
  void mount(Element target, [Node? anchor]) {
    insert(target, button1, anchor);
    append(button1, t1);
    append(button1, t2);
    append(button1, t3);
    append(button1, t4);

    if (!mounted) {
      dispose = listen(button1, 'click', (event) {
        context.handleClick();
        markDirty('count');
      });
    }
  }

  @override
  void update(Set<String> aspects) {
    if (aspects.contains('count')) {
      setData(t2, '${context.count}');

      if (t4value != (t4value = context.count == 1 ? 'time' : 'times')) {
        setData(t4, t4value);
      }
    }
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(button1);
    }

    mounted = false;
    dispose();
  }
}
```