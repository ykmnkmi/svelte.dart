<script>
  import 'package:svelte/svelte.dart';
  import 'package:web/web.dart';

  var m = state<List<int>>([0, 0]);

  void handleMouseMove(MouseEvent event) {    
    m[0] = event.clientX;
    m[1] = event.clientY;
  }
</script>

<div onmousemove={handleMousemove}>
  The mouse position is {m[0]} x {m[1]}
</div>

<style>
  div {
    width: 100%;
    height: 100%;
  }
</style>