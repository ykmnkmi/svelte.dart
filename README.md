svelte.dart
===========

[Svelte][Svelte] ([v5.6.16][v5.6.16]) web framework, (not yet) ported to [Dart][Dart].

| Package | Description | Version |
|---|---|---|
| [svelte_ast](svelte_ast/) | Parser and utilities for SvelteDart template compiler.| [![Pub Package][ast_pub_icon]][ast_pub] |

```html
<!-- app.svelte -->
<script>
  // imports
  import 'package:svelte/svelte.dart';

  // properties
  external int step = 1;

  // body
  int count = $state(0);
  int doubled = $derived(count * 2);
  int quadrupled = $derived(doubled * 2);

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

Status:
- [x] Parser
  - version 5 support 🔥
- [ ] Runtime
  - [ ] internal 🔥
  - [ ] ...
- [ ] Compiler
- [ ] Builder
- [ ] Examples (to test runtime, not generated)
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
[v5.6.16]: https://github.com/sveltejs/svelte/tree/svelte%405.6.16
[ast_pub_icon]: https://img.shields.io/pub/v/svelte_ast.svg
[ast_pub]: https://pub.dev/packages/svelte_ast
