<script>
  import 'package:svelte/svelte.dart';

  @bindable
  external String value = '';
  
  external void Function() onSubmit;

  void select(String num) {
    value += num;
  }

  void clear() {
    value = '';
  }
</script>

<div class="keypad">
  <button onclick={select('1')}>1</button>
  <button onclick={select('2')}>2</button>
  <button onclick={select('3')}>3</button>
  <button onclick={select('4')}>4</button>
  <button onclick={select('5')}>5</button>
  <button onclick={select('6')}>6</button>
  <button onclick={select('7')}>7</button>
  <button onclick={select('8')}>8</button>
  <button onclick={select('9')}>9</button>

  <button disabled={value.isEmpty} on:click={clear}>clear</button>
  <button on:click={select('0')}>0</button>
  <button disabled={value.isEmpty} on:click={onSubmit}>submit</button>
</div>

<style>
  .keypad {
    display: grid;
    grid-template-columns: repeat(3, 5em);
    grid-template-rows: repeat(4, 3em);
    grid-gap: 0.5em;
  }

  button {
    margin: 0;
  }
</style>