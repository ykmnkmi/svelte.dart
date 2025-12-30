<script>
  import 'package:svelte/svelte.dart';
  import 'package:web/web.dart';

  var pin = state<String>('');

  var view = derived<String>(pin.isNotEmpty ? pin.replace(RegExp('\\d+(?!\$)'), '•') : 'enter your pin');

  void handleSubmit() {
    window.alert('submitted $pin');
  }
</script>

<h1 class:pin={pin.isNotEmpty}>{view}</h1>

<Keypad bind:value={pin} onSubmit={handleSubmit} />

<style>
  h1 {
    color: #ccc;
  }

  h1.pin {
    color: #333;
  }

  :global(body.dark) h1 {
    color: #444;
  }

  :global(body.dark) h1.pin {
    color: #fff;
  }
</style>