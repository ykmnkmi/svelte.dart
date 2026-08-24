<script type="text/x-dart">
  import 'package:svelte/svelte.dart';

  var answer = prop<int?>();
</script>

<p>The answer is {answer()}</p>