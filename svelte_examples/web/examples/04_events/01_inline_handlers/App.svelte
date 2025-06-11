<script>
  import 'package:svelte/svelte.dart';
  import 'package:web/web.dart';

  var m = state<List<int>>([0, 0]);
</script>

<!-- svelte-ignore a11y_no_static_element_interactions -->
<div onmousemove={(MouseEvent event) {
  m = [event.clientX, event.clientY];
}}>
  The mouse position is {m[0]} x {m[1]}
</div>

<style>
  div {
    width: 100%;
    height: 100%;
  }
</style>