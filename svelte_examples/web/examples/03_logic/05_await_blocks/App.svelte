<script type="application/dart">
  import 'package:svelte_runtime/svelte_runtime.dart';

  Future<int> getRandomNumber() {
    var random = Random();

    if (random.nextBool()) {
      return Future<int>.value(random.nextInt(0xFF));
    }

    return Future<int>.error(StateError('No luck!'));
  }

  var future = state<Future<int>>(getRandomNumber());

  void handleClick() {
    future.set(getRandomNumber());
  }
</script>

<button onclick={handleClick}>generate random number</button>

{#await future()}
  <p>...waiting</p>
{:then number}
  <p>The number is {number}</p>
{:catch error}
  <p style="color: red">{error}</p>
{/await}