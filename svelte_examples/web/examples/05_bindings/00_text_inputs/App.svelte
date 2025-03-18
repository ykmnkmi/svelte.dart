<script type="application/dart">
  import 'package:svelte_runtime/svelte_runtime.dart';

  var name = state<String>('');
</script>

<input bind:value={name} placeholder="enter your name" />
<p>Hello {name().isEmpty ? 'stranger' : name()}!</p>