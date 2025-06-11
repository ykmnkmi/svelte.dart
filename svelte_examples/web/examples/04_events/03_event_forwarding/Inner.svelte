<script>
  external void Function({required String text}) onMessage;

  void sayHello(Event event) {
    onMessage(text: 'Hello!');
  }
</script>

<button onclick={sayHello}>Click to say hello</button>