svelte.dart
===========

[Svelte](https://svelte.dev/) ([v3.59.2](https://github.com/sveltejs/svelte/tree/v3.59.2))
web framework, (not yet) ported to [Dart](https://dart.dev).

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
    - [ ] dom `dart:html` 🔥
      - [ ] `package:web`
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
