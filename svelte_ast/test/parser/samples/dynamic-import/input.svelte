<script>
  import 'package:svelte/svelte.dart' show onMount;

  import 'foo.dart' deferred as foo;

  onMount(() async {
    await foo.loadLibrary();
    print(foo.main);
  });
</script>