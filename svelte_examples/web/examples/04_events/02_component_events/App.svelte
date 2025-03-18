<script type="application/dart">
  import 'package:svelte_runtime/svelte_runtime.dart';

  import 'Inner.svelte';

  void handleMessage({required String text}) {
    window.alert(text);
  }
</script>

<Inner onMessage={handleMessage} />