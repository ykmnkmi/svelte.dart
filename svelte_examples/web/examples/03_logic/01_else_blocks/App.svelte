<script>
  import 'package:svelte/svelte.dart';

  import 'user.dart';

  var user = state<User>(User(loggedIn: false));

  void toggle() {
    user.loggedIn = !user.loggedIn;
  }
</script>

{#if user.loggedIn}
  <button onclick={toggle}>Log out</button>
{:else}
  <button onclick={toggle}>Log in</button>
{/if}