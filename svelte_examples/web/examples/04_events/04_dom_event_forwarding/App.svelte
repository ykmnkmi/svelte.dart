<script type="text/x-dart">
  import 'package:web/web.dart';

  import 'CustomButton.svelte';

  void handleClick(Event event) {
    window.alert('clicked');
  }
</script>

<CustomButton onclick={handleClick} />