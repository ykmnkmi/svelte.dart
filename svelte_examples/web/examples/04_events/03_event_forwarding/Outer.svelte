<script type="text/x-dart">
  import 'package:svelte/svelte.dart';

  import 'Inner.svelte';

  var onMessage = prop<void Function({required String text})>();
</script>

<Inner {onMessage} />