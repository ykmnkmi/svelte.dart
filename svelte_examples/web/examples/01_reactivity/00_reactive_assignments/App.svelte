<script>
  import 'package:svelte/svelte.dart';

  var count = state<int>(0);

  void handleClick() {
    count += 1;
  }
</script>

<button onclick={handleClick}>
  Clicked {count}
  {count == 1 ? 'time' : 'times'}
</button>