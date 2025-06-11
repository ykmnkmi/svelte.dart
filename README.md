svelte.dart
===========

> Experimenting, work in progress.

[Svelte][Svelte] ([v5.16.6][v5.16.6]) web framework (not yet) ported to [Dart][Dart].

| Package | Description | Version |
|---|---|---|
| [svelte_ast](svelte_ast/) | Parser and utilities for SvelteDart template compiler.| [![Pub Package][ast_pub_icon]][ast_pub] |

Dart port of the Svelte framework.

```html
<!-- app.svelte -->
<script>
  // imports
  import 'package:svelte/svelte.dart';

  // properties
  external int step = 1;

  // body
  int count = state<int>(0);
  int doubled = derived<int>(count * 2);
  int quadrupled = derived<int>(doubled * 2);

  void handleClick() {
    count += step;
  }

  const duration = Duration(seconds: 1);

  onMount(() {
    var timer = Timer.periodic(duration, (_) {
      count += 1;
    });

    return () {
      timer.cancel();
    };
  });
</script>

<button onclick={handleClick}>
  Clicked {count} {count == 1 ? 'time' : 'times'}
</button>

<p>{count} * 2 = {doubled}</p>
<p>{doubled} * 2 = {quadrupled}</p>
```

Another way of writing components, inspired by Flutter/Jaspr. It should be
compiled the same way as the HTML component above, not _executed_ as is.

```dart
// app.dart

import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

Node app({int step = 1}) {
  int count = state<int>(0);
  int doubled = derived<int>(count * 2);
  int quadrupled = derived<int>(doubled * 2);

  void handleClick() {
    count += step;
  }

  const duration = Duration(seconds: 1);

  onMount(() {
    var timer = Timer.periodic(duration, (_) {
      count += 1;
    });

    return () {
      timer.cancel();
    };
  });

  return fragment([
    button(onClick: handleClick, [
      text('Clicked $count ${count == 1 ? 'time' : 'times'}'),
    ]);
    p([text('$count * 2 = $doubled')]),
    p([text('$doubled * 2 = $quadrupled')]),
  ]);
}
```

Both ways should output same code after compilation:

```dart
// ignore: library_prefixes
import 'package:svelte_runtime/src/internal.dart' as $;
import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart';

base class App extends Component {
  static final root = $.template<DocumentFragment>(
    '<button> </button> <p> </p> <p> </p>',
    1,
  );

  App({this.count = 1});

  int count;

  @override
  void call(Node anchor) {
    var count = state<int>(0);
    var doubled = derived<int>(() => count() * 2);
    var quadrupled = derived<int>(() => doubled() * 2);

    void handleClick() {
      count.set(count() + 1);
    }

    var fragment = root();
    var button = $.firstChild<HTMLButtonElement>(fragment);
    var text = $.child<Text>(button);

    $.reset(button);

    var p = $.sibling<HTMLParagraphElement>(button, 2);
    var text1 = $.child<Text>(p);

    $.reset(p);

    var p1 = $.sibling<HTMLParagraphElement>(p, 2);
    var text2 = $.child<Text>(p1);

    $.reset(p1);

    $.templateEffect(() {
      $.setText(text, 'Count ${count()} ${count() == 1 ? 'time' : 'times'}');
      $.setText(text1, '${count()} * 2 = ${doubled()}');
      $.setText(text2, '${doubled()} * 2 = ${quadrupled()}');
    });

    $.eventVoid('click', button, handleClick);
    $.append(anchor, fragment);
  }
}
```

Can we use Dart code without generators? Yes, this is Solid way:

```dart
// app.dart

import 'package:svelte/svelte.dart';

Component app({int step = 1}) {
  State<int> count = State<int>(0);
  Derived<int> doubled = Derived<int>(() => count() * 2);
  Derived<int> quadrupled = Derived<int>(() => doubled() * 2);

  void handleClick(Event event) {
    count.set(count() + step);
  }

  const duration = Duration(seconds: 1);

  onMount(() {
    var timer = Timer.periodic(duration, (_) {
      count.set(count() + step);
    });

    return () {
      timer.cancel();
    };
  });

  return Fragment([
    Button(
      onClick: handleClick,
      children: [
        Text.derived(() => 'Clicked ${count()} ${count() == 1 ? 'time' : 'times'}'),
      ],
    );
    P(
      children: [
        Text.derived(() => '${count()} * 2 = ${doubled()}'),
      ],
    ),
    P(
      children: [
        Text.derived(() => '${doubled()} * 2 = ${quadrupled()}'),
      ],
    ),

    // Flow ...
    If(
      test: stateOrCallable,
      children: [
        // ...
      ],
    ),
    Each(
      values: stateOrCallable,
      children: [
        // ...
      ],
    ),
    Key(
      key: stateOrCallable,
      children: [
        // ...
      ],
    ),
  ]);
}
```

Reactive properties should be passed as is:

```dart
// app.dart

import 'package:svelte/svelte.dart';

Node app({State<int>? counter}) {
  // ...
}
```

What about attributes? There is 2 ways - each property as argument or single map.

As arguments, typed, with if null checks for each. Unused arguments should be
tree-shaken by the compiler.

```dart
Button(
  className: 'btn btn-blue',
  onClick: handleClick,
  // String? title,
  // Ignore first when reactive title is used. Would be nice to have StateOr<T>.
  // State<String>? titleState,
  titleState: title,
  children: [
    // ...
  ],
);
```

Map, untyped, single iteration over all attributes with 3 ~ 4 if checks.

```dart
Button(
  attributes: {
    'class': 'btn btn-blue',
    'onclick': handleClick,
    'title': title, // state
  },
  children: [
    // ...
  ],
);
```

Component function is called once per mount and builds the reactive graph.

Status:
- [x] Parser
- [ ] Runtime
  - [ ] internal 🔥
  - [ ] ...
- [ ] Compiler
- [ ] Builder
- [ ] Examples (to test runtime and JS interop., not generated):
  - [x] introduction
  - [x] reactivity
  - [x] props
  - [x] logic
  - [x] events
  - [ ] bindings 🔥
  - [ ] ...
- [ ] ...
- [ ] SSR
  - shelf
  - ...

[Svelte]: https://svelte.dev
[Dart]: https://dart.dev
[v5.16.6]: https://github.com/sveltejs/svelte/tree/svelte%405.16.6
[ast_pub_icon]: https://img.shields.io/pub/v/svelte_ast.svg
[ast_pub]: https://pub.dev/packages/svelte_ast
