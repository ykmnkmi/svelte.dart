<script type="application/dart">
  import 'package:svelte_runtime/svelte_runtime.dart';

  var w = state<int>(0);
  var h = state<int>(0);
  var size = state<int>(42);
  var text = state<String>('edit me');
</script>

<input type="range" bind:value={size} />
<input bind:value={text} />

<p>size: {w()}px x {h()}px</p>

<div bind:clientWidth={w} bind:clientHeight={h}>
  <span style="font-size: {size()}px">{text()}</span>
</div>

<style>
  div.svelte-11bzk4c {
    position: relative;
  }

  .controls.svelte-11bzk4c {
    position: absolute;
    top: 0;
    width: 100%;
    transition: opacity 1s;
  }

  .info.svelte-11bzk4c {
    display: flex;
    width: 100%;
    justify-content: space-between;
  }

  span.svelte-11bzk4c {
    padding: 0.2em 0.5em;
    color: white;
    text-shadow: 0 0 8px black;
    font-size: 1.4em;
    opacity: 0.7;
  }

  .time.svelte-11bzk4c {
    width:3em;
  }

  .time.svelte-11bzk4c:last-child {
    text-align:right;
  }

  progress.svelte-11bzk4c {
    display:block;
    width:100%;
    height:10px;
    -webkit-appearance:none;
    appearance:none;
  }

  progress.svelte-11bzk4c::-webkit-progress-bar {
    background-color:rgba(0, 0, 0, 0.2);
  }

  progress.svelte-11bzk4c::-webkit-progress-value {
    background-color:rgba(255, 255, 255, 0.6);
  }

  video.svelte-11bzk4c {
    width:100%;
  }
</style>