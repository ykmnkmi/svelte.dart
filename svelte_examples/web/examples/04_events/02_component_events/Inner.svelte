<script type="text/x-dart">
  import 'package:svelte/svelte.dart';

  var onMessage = prop<void Function({required String text})>();

  void sayHello() {
    onMessage()(text: 'Hello!');
  }
</script>

<button onclick={sayHello}>Click to say hello</button>