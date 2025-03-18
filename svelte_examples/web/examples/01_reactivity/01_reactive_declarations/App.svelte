<script type="application/dart">
  import 'package:svelte_runtime/svelte_runtime.dart';

  var count = state<int>(1);

  var doubled = derived<int>(() => count() * 2);
  var quadrupled = derived<int>(() => doubled() * 2);

  void handleClick() {
    count.set(count() + 1);
  }
</script>

<button onclick={handleClick}>
  Count: {count()}
</button>

<p>{count()} * 2 = {doubled()}</p>
<p>{doubled()} * 2 = {quadrupled()}</p>