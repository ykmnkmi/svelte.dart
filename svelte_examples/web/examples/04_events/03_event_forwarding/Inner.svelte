<script type="application/dart">
  import 'package:svelte_runtime/svelte_runtime.dart';
  
  external void Function({required String text}) onMessage;

  void sayHello() {
    onMessage(text: 'Hello!');
  }
</script>

<button onclick={sayHello}> Click to say hello </button>