svelte.dart
===========

[Svelte][Svelte] ([v4.2.19][v4.2.19]) web framework, (not yet) ported to [Dart][Dart].

| Package | Description | Version |
|---|---|---|
| [svelte_ast](svelte_ast/) | Parser and utilities for SvelteDart template compiler.| [![Pub Package][ast_pub_icon]][ast_pub] |

```html
<!-- app.svelte -->
<script>
  // imports
  import 'package:svelte/svelte.dart';

  // properties
  external int count = 0;

  // body
  $: doubled = count * 2;
  $: quadrupled = doubled * 2;

  void handleClick() {
    count += 1;
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

<button on:click={handleClick}>
  Clicked {count} {count == 1 ? 'time' : 'times'}
</button>

<p>{count} * 2 = {doubled}</p>
<p>{doubled} * 2 = {quadrupled}</p>
```

Status:
- [x] Parser
- [ ] Runtime
  - [ ] internal
    - [ ] component 🔥
    - [x] scheduler
    - [ ] lifecycle 🔥
    - [ ] dom `package:web` 🔥
    - [ ] transition 🔥
  - [ ] ...
- [ ] Compiler 🔥
- [ ] Builder
- [ ] Examples (to test runtime, not generated)
  - [x] introduction
  - [x] reactivity
  - [x] props
  - [ ] logic 🔥
  - [ ] ...
- [ ] ...
- [ ] SSR
  - shelf
  - ...

[Svelte]: https://svelte.dev
[Dart]: https://dart.dev
[v4.2.19]: https://github.com/sveltejs/svelte/tree/svelte%404.2.19
[ast_pub_icon]: https://img.shields.io/pub/v/svelte_ast.svg
[ast_pub]: https://pub.dev/packages/svelte_ast
