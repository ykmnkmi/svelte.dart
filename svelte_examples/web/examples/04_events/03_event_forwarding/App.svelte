<script type="text/x-dart">
  import 'package:web/web.dart';

  import 'Outer.svelte';

  void handleMessage({required String text}) {
    window.alert(text);
  }
</script>

<Outer onMessage={handleMessage} />