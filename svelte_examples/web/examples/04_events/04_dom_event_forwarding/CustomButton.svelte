<script type="application/dart">
  import 'package:svelte_runtime/svelte_runtime.dart';
  import 'package:web/web.dart';

  external void Function(Event event) onClick;
</script>

<button {onclick}>Click me</button>

<style>
  button {
    height: 4rem;
    width: 8rem;
    background-color: #aaa;
    border-color: #f1c40f;
    color: #f1c40f;
    font-size: 1.25rem;
    background-image: linear-gradient(45deg, #f1c40f 50%, transparent 50%);
    background-position: 100%;
    background-size: 400%;
    transition: background 300ms ease-in-out;
  }

  button:hover {
    background-position: 0;
    color: #aaa;
  }
</style>