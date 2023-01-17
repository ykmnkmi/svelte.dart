<svelte:options dispatcher />

<script type="text/dart">
  @input
  var count = 0;

  var dispatchEven = createEventDispatcher<int>('even');
  var dispatchOdd = createEventDispatcher<int>('odd');

  // same as `$:`
  void onChanges() {
    if (count.isEven) {
      dispatchEven(count);
    } else {
      dispatchOdd(count);
    }
  }
</script>

Clicked {count} {count == 1 ? 'time' : 'times'} <slot name="zero">, click it</slot>!