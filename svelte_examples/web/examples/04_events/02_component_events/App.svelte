<script type="text/x-dart">
  import 'package:web/web.dart';

  import 'Inner.svelte';

  void handleMessage({required String text}) {
    window.alert(text);
  }
</script>

<Inner onMessage={handleMessage} />