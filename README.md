svelte.dart
===========

[Svelte](https://svelte.dev/) ([v3.55.1](https://github.com/sveltejs/svelte/tree/v3.55.1))
web framework ported to [Dart](https://dart.dev).

**Branches**

Component instance

```html
<script>
  var count = 0;

  $: ...

  onMount(() {
    // ...
  });

  void handleClick() {
    count += 1;
  }
</script>
```

- master - original svelte implementation where instance declaration is *inside* instance function

  ```dart
  Fragment createFragment() {
    // ...
  }

  List instance(component, ..., invalidate) {
    var count = 0;

    // $: ...

    onMount(() {
      // ...
    });

    void handleClick() {
      invalidate(0, count += 1);
    }

    return [count, handleClick];
  }

  class App extends Component {
    App({Element? target, ... }) {
      init(this, instance, createFragment, ...);
    }
  }

  void main() {
    App(target: document.body);
  }
  ```

  Can use `$:` syntax and lifecycle hooks, but not `@annotation`'s.

- class - svelte implementation where instance declaration is *inside* class component

  ```dart
  class App extends Component {
    int _count = 0;

    int get count {
      return _count;
    }

    set count(int value) {
      if (_count != (_count = value)) {
        makeComponentDirty(this, 0);
      }
    }

    void handleClick() {
      count += 1;
    }

    @override
    void onMount() {
      // ...
    }

    @override
    void update() {
      // $: ...
    }

    @override
    Fragment render(Element target) {
      // ...
    }
  }

  void main() {
    runApp(App(), target: document.body);
  }
  ```

  Can use `@annotation`'s, but not `$:` syntax and lifecycle hooks.

TODO:
- [ ] Parser ✔️
  - [ ] Style
- [ ] Runtime
  - [ ] internal 🔥
  - ...
- [ ] Compiler
- [ ] Builder
- [ ] Tests
- ...
- [ ] SSR (shelf first)
