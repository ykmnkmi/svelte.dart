<script type="application/dart">
  import 'package:svelte_runtime/svelte_runtime.dart';

  import 'Inner.svelte';

  external void Function({required String text}) onMessage;
</script>

<Inner {onMessage} />