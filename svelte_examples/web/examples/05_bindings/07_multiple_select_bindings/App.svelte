<script type="application/dart">
  import 'package:svelte_runtime/svelte_runtime.dart';

  var scoops = state<int>(1);
  var flavours = state<List<String>>(<String>['Mint choc chip']);

  var menu = <String>[
    'Cookies and cream',
    'Mint choc chip',
    'Raspberry ripple',
  ];

  String join(List<String> flavours) {
    if (flavours.length == 1) {
      return flavours[0];
    }

    return '${flavours.take(flavours.length - 1).join(', ')} and ${flavours.last}';
  }
</script>

<h2>Size</h2>

<label>
  <input type="radio" bind:group={scoops} value={1} />
  One scoop
</label>

<label>
  <input type="radio" bind:group={scoops} value={2} />
  Two scoops
</label>

<label>
  <input type="radio" bind:group={scoops} value={3} />
  Three scoops
</label>

<h2>Flavours</h2>

<select multiple bind:value={flavours}>
  {#each menu as flavour}
    <option value={flavour}>
      {flavour}
    </option>
  {/each}
</select>

{#if flavours().isEmpty}
  <p>Please select at least one flavour</p>
{:else if flavours().length > scoops()}
  <p>Can't order more flavours than scoops!</p>
{:else}
  <p>
    You ordered {scoops()}
    {scoops() === 1 ? 'scoop' : 'scoops'}
    of {join(flavours())}
  </p>
{/if}