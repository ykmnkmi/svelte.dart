<script type="application/dart">
  import 'package:svelte_runtime/svelte_runtime.dart';
  import 'package:web/web.dart';

  var m = state<List<int>>(<int>[0, 0]);
</script>

<!-- svelte-ignore a11y_no_static_element_interactions -->
<div onmousemove={(MouseEvent event) {
  m.set(<int>[event.clientX, event.clientY]);
}}>
  The mouse position is {m().x} x {m().y}
</div>

<style>
  div {
    width: 100%;
    height: 100%;
  }
</style>