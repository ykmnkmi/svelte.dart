<script type="application/dart">
  import 'package:svelte_runtime/svelte_runtime.dart';

  var count = state<int>(0);

  void handleClick() {
    count.set(count() + 1);
  }
</script>

<button onclick={handleClick}>
  Clicked {count()}
  {count() == 1 ? 'time' : 'times'}
</button>