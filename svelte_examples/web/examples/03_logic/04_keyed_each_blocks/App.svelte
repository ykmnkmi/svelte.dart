<script type="application/dart">
  import 'package:svelte_runtime/svelte_runtime.dart';

  import 'Thing.svelte';

  var things = state<List<({String color, int id})>>([
    (id: 1, color: 'darkblue'),
    (id: 2, color: 'indigo'),
    (id: 3, color: 'deeppink'),
    (id: 4, color: 'salmon'),
    (id: 5, color: 'gold'),
  ]);

  void handleClick() {
    things.update((things) {
      things.removeAt(0);
    });
  }
</script>

<button onclick={handleClick}>Remove first thing</button>

<div style="display: grid; grid-template-columns: 1fr 1fr; grid-gap: 1em">
  <div>
    <h2>Keyed</h2>
    {#each things() as thing (thing.id)}
      <Thing current={thing.color} />
    {/each}
  </div>

  <div>
    <h2>Unkeyed</h2>
    {#each things() as thing}
      <Thing current={thing.color} />
    {/each}
  </div>
</div>