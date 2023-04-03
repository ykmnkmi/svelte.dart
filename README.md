svelte.dart
===========

[Svelte](https://svelte.dev/) ([v3.55.1](https://github.com/sveltejs/svelte/tree/v3.55.1))
web framework, (not yet) ported to [Dart](https://dart.dev).

- Original implementation.

  ```html
  <!-- app.svelte -->

  <script>
    import 'package:svelte/svelte.dart' show onMount;

    var count = 0;

    $: doubled = count * 2;
    $: quadrupled = doubled * 2;

    void handleClick() {
      count += 1;
    }

    onMount(() {
      var timer = Timer.periodic(Duration(seconds: 2), (_) {
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

- React\Solid way.

  Functional сomponent and Svelte syntax.
  Original Svelte API, hard to extend the parser of the Dart language.

  ```dart
  // app.dartx

  import 'package:svelte/svelte.dart' show onMount, onDestroy;

  Fragment app( /* props, slots */ ) {
    var count = 0;

    $: doubled = count * 2;
    $: quadrupled = doubled * 2;

    void handleClick() {
      count += 1;
    }

    late Timer timer;

    onMount(() {
      timer = Timer.periodic(Duration(seconds: 2), (_) {
        count += 1;
      });
    });

    onDestroy(() {
      timer.cancel();
    });

    return (
      <button on:click={handleClick}>
        Clicked {count} {count == 1 ? 'time' : 'times'}
      </button>

      <p>{count} * 2 = {doubled}</p>
      <p>{doubled} * 2 = {quadrupled}</p>
    );
  }
  ```

- NgComponent way.

  Angular Component API, Svelte template syntax and reactivity. Easy to implement, same as NgDart.

  ```dart
  import 'package:svelte/svelte.dart' show Component, OnMount, OnDestroy;

  @Component(
    tag: 'app',
    template: '''
      <button on:click={handleClick}>
        Clicked {count} {count == 1 ? 'time' : 'times'}
      </button>

      <p>{count} * 2 = {doubled}</p>
      <p>{doubled} * 2 = {quadrupled}</p>
  ''',
  )
  class App implements OnMount, OnDestroy {
    int count = 0;

    late int doubled = count * 2;

    late int quadrupled = doubled * 2;

    void handleClick() {
      count += 1;
    }

    late Timer timer;

    @override
    void onMount() {
      timer = Timer.periodic(Duration(seconds: 2), (_) {
        count += 1;
      });
    }

    @override
    void onDestroy() {
      timer.cancel();
    }
  }
  ```

Status (original implementation):
- [x] Parser
  - [ ] Style
- [ ] Runtime
  - [ ] internal
    - [ ] component 🔥
    - [x] scheduler
    - [ ] lifecycle 🔥
    - [ ] dom `dart:html` 🔥
      - [ ] `package:js`
      - [ ] `package:web`
    - [ ] transition
  - [ ] ...
- [ ] Compiler
  - [ ] Builder 🔥
- [ ] Tests
  - [x] Parser
  - [ ] Runtime
  - [ ] ...
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
