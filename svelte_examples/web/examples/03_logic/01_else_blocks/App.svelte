<script type="text/x-dart">
  import 'user.dart';

  var user = User(loggedIn: false);

  void toggle() {
    user.loggedIn = !user.loggedIn;
  }
</script>

{#if user.loggedIn}
  <button onclick={toggle}>Log out</button>
{:else}
  <button onclick={toggle}>Log in</button>
{/if}