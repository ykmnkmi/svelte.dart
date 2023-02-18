svelte.dart
===========

[Svelte](https://svelte.dev/) ([v3.55.1](https://github.com/sveltejs/svelte/tree/v3.55.1))
web framework, (not yet) ported to [Dart](https://dart.dev).

Why? ... :
- _Original_ implementation.

  _WIP_

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

      return timer.cancel;
    });
  </script>

  <button on:click={handleClick}>
    Clicked {count} {count == 1 ? 'time' : 'times'}
  </button>

  <p>{count} * 2 = {doubled}</p>
  <p>{doubled} * 2 = {quadrupled}</p>
  ```

- React\Solid way.

  Functional сomponent and Svelte ыyntax. Original Svelte API, hard (it takes a lot of time to experiment with the API) to extend the parser of the Dart language.

  ```dart
  // app.dartx

  import 'package:svelte/svelte.dart' show onMount, onDestroy;

  Fragment app() {
    var count = 0;

    $: doubled = count * 2;
    $: quadrupled = doubled * 2;

    void handleClick() {
      count += 1;
    }

    // another way
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

  Angular Component API, Svelte template syntax and reactivity. It's easy to implement, same as NgDart.

  ```dart
  import 'package:svelte/svelte.dart' show OnChanges, OnMount, OnDestroy;

  @Component(
    selector: 'app',
    template: r'''
  <button on:click={handleClick}>
    Clicked {count} {count == 1 ? 'time' : 'times'}
  </button>

  <p>{count} * 2 = {doubled}</p>
  <p>{doubled} * 2 = {quadrupled}</p>
  ''',
  )
  class App implements OnChanges, OnMount, OnDestroy {
    int count = 0;

    late int doubled = count * 2;
    late int quadrupled = doubled * 2;

    void handleClick() {
      count += 1;
    }

    @override
    void onChanges() {
      doubled = count * 2;
      quadrupled = doubled * 2;
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

Status (Original):
- [x] Parser
  - [ ] Style
- [ ] Runtime
  - [ ] internal
    - [ ] component 🔥
    - [x] scheduler
    - [ ] lifecycle 🔥
    - [ ] dom `dart:html` 🔥
      - [ ] `package:js`
    - [ ] transition
  - [ ] ...
- [ ] Compiler
  - [ ] Builder
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
- [ ] SSR (shelf first)
