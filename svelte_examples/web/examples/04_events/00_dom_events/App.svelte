<script type="application/dart">
  import 'package:svelte_runtime/svelte_runtime.dart';
  import 'package:web/web.dart';

  var m = state<List<int>>(<int>[0, 0]);

  void handleMouseMove(MouseEvent event) {
    m.update((m) {
      m[0] = event.clientX;
      m[1] = event.clientY;
    });
  }
</script>

<div onmousemove={handleMousemove}>
  The mouse position is {m().x} x {m().y}
</div>

<style>
  div {
    width: 100%;
    height: 100%;
  }
</style>