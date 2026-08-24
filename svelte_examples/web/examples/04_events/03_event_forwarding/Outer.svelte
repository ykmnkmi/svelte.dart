<script type="text/x-dart">
  import 'Inner.svelte';

  external void Function({required String text}) onMessage;
</script>

<Inner {onMessage} />