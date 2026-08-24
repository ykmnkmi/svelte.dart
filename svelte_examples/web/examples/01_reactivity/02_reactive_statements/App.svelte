<script type="text/x-dart">
  import 'package:svelte/svelte.dart';
  import 'package:web/web.dart';

  var count = state<int>(0);

  effect(() {
    if (count() >= 10) {
      window.alert(`count is dangerously high!`);
      count.set(9);
    }
  });

  void handleClick() {
    count.set(count() + 1);
  }
</script>

<button onclick={handleClick}>
  Clicked {count()}
  {count() == 1 ? 'time' : 'times'}
</button>