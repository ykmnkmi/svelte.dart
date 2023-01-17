<script type="text/dart">
  import 'nested.dart';

  var count = 0;

  void handleClick() {
    count += 1;
  }

  void logEven(int count) {
    print('even: $count');
  }

  void logOdd(int count) {
    print('odd: $count');
  }
</script>

<button on:click={handleClick}>
  <Nested {count} on:even={logEven} on:odd={logOdd}>
    <fragment slot="zero">
      {#if count == 0}
        , click this button
      {:else if count.isOdd}
        is odd!
      {:else}
        is even!
      {/if}
    </fragment>
  </Nested>
</button>