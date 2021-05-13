piko.dart
=========

[React](https://reactjs.com) looking [Svelte](https://svelte.dev) based framework for [Dart](https://dart.dev).

Plan
====

Stage 1: able to handle static html with `{ variable }`
- fragment compiler
  - parser
  - generator
- dartx compiler
  - parser
  - builder
- VS Code extension
  - syntax highlighter
  - language server

Stage 2:
- event handlers
- change detector
- ...

Example
=======
from:
```
import 'package:piko/internal.dart';

class App extends Component<App> {
  App({this.name = 'world'});
  
  final String name;

  @override
  Fragment<App> render(RenderTree tree) {
    return <p id="title">hello { name }!</p>;
  }
}
```

to:
```
library app;

import 'dart:html';

import 'package:piko/runtime.dart';

class App extends Component<App> {
  App({this.name = 'world'});

  final String name;

  @override
  Fragment<App> render(RenderTree tree) {
    return AppFragment(this, tree);
  }
}

class AppFragment extends Fragment<App> {
  AppFragment(App context, RenderTree tree) : super(context, tree);

  // `late` is too much here, node `!` checks drops after compiling

  Element? p1;

  Text? t1;

  Text? t2;

  Text? t3;

  @override
  void create() {
    p1 = element('p');
    t1 = text('hello ');
    t2 = text(context.name);
    t3 = text('!');
    attr(p1!, 'id', 'title');
  }

  @override
  void mount(Element target, [Node? anchor]) {
    insert(target, p1!, anchor);
    append(p1!, t1!);
    append(p1!, t2!);
    append(p1!, t3!);
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(p1!);
    }
  }
}
```