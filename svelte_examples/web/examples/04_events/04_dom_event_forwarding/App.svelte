<script type="application/dart">
  import 'package:svelte_runtime/svelte_runtime.dart';
  import 'package:web/web.dart';

  import 'CustomButton.svelte';

  void handleClick(Event event) {
    window.alert('clicked');
  }
</script>

<CustomButton onclick={handleClick} />