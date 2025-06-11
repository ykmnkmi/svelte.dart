<script>
  import 'package:svelte/svelte.dart';

  var name = state<String>('');
</script>

<input bind:value={name} placeholder="enter your name" />
<p>Hello {name.isEmpty ? 'stranger' : name}!</p>