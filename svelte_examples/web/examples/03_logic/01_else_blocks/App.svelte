<script type="application/dart">
  import 'package:svelte_runtime/svelte_runtime.dart';

  import 'user.dart';

  var user = state<User>(User(loggedIn: false));

  void toggle() {
    user.update((user) {
      user.loggedIn = !user.loggedIn;
    });
  }
</script>

{#if user().loggedIn}
  <button onclick={toggle}>Log out</button>
{:else}
  <button onclick={toggle}>Log in</button>
{/if}