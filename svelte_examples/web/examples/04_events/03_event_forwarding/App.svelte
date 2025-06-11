<script>
  import 'package:web/web.dart';

  import 'Outer.svelte';

  void handleMessage({required String text}) {
    window.alert(text);
  }
</script>

<Outer onMessage={handleMessage} />