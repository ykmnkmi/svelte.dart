<script>
  import 'package:svelte/svelte.dart';

  var w = state<int>(0);
  var h = state<int>(0);
  var size = state<int>(42);
  var text = state<String>('edit me');
</script>

<input type="range" bind:value={size} />
<input bind:value={text} />

<p>size: {w}px x {h}px</p>

<div bind:clientWidth={w} bind:clientHeight={h}>
  <span style="font-size: {size}px">{text}</span>
</div>

<style>
  input {
    display: block;
  }
  div {
    display: inline-block;
  }
</style>