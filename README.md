svelte.dart
===========

> Experimenting, work in progress.

[Svelte][Svelte] ([v5.16.6][v5.16.6]) web framework (not yet) ported to [Dart][Dart].

| Package | Description | Version |
|---|---|---|
| [svelte_ast](svelte_ast/) | Parser and utilities for SvelteDart template compiler.| [![Pub Package][ast_pub_icon]][ast_pub] |

Dart port of the Svelte framework with no magic transofrmations.

**WIP**. **EXPERIMENTAL**. Third iteration.

```html
<!-- app.svelte -->
<script>
  import 'dart:async';

  import 'package:svelte/svelte.dart';

  var step = prop<int>(1);

  var count = state<int>(0);
  var doubled = derived<int>(() => count() * 2);
  var quadrupled = derived<int>(() => doubled() * 2);

  void handleClick() {
    count.set(count() + step());
  }

  onMount(() {
    var timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      count.increment();
    });

    return () {
      timer.cancel();
    };
  });
</script>

<button onclick={handleClick}>
  Clicked {count()} {count() == 1 ? 'time' : 'times'}
</button>

<p>{count()} * 2 = {doubled()}</p>
<p>{doubled()} * 2 = {quadrupled()}</p>
```

Which should be compiled to this:

```dart
import 'dart:async';

import 'package:svelte/svelte.dart';

import 'package:svelte/src/internal.dart' as $;
import 'package:web/web.dart';

base class App extends Component {
  static final root = $.template<DocumentFragment>(
    '<button> </button> <p> </p> <p> </p>',
    1,
  );

  App({int step = 1}) : step = prop<int>(step);

  Prop<int> step;

  @override
  void call(Node anchor) {
    var count = state<int>(0);
    var doubled = derived<int>(() => count() * 2);
    var quadrupled = derived<int>(() => doubled() * 2);

    void handleClick() {
      count.set(count() + step());
    }

    onMount(() {
      final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        count.increment();
      });

      return () {
        timer.cancel();
      };
    });

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
      $.setText(text, 'Clicked ${count()} ${count() == 1 ? 'time' : 'times'}');
      $.setText(text1, '${count()} * 2 = ${doubled()}');
      $.setText(text2, '${doubled()} * 2 = ${quadrupled()}');
    });

    $.eventVoid('click', button, handleClick);
    $.append(anchor, fragment);
  }
}
```

Status:
- [x] Parser
- [ ] Runtime
  - [ ] internal 🔥
  - [ ] ...
- [ ] Compiler/Transofrmer
- [ ] Builder/Generator 🔥
  - `.svelte` > `.svelte.dart`
  - `.svelte.dart` > `.dart`
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
[v5.16.6]: https://github.com/sveltejs/svelte/tree/svelte@5.16.6
[ast_pub_icon]: https://img.shields.io/pub/v/svelte_ast.svg
[ast_pub]: https://pub.dev/packages/svelte_ast
