<script type="text/x-dart">
  import 'package:svelte/svelte.dart';

  var answer = prop<Object>('a mystery');
</script>

<p>The answer is {answer()}</p>