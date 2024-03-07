<script type="application/dart">
	import 'user.dart';

	var user = User(loggedIn: false);

	void toggle() {
		user.loggedIn = !user.loggedIn;
	}
</script>

{#if user.loggedIn}
	<button on:click={toggle}> Log out </button>
{:else}
	<button on:click={toggle}> Log in </button>
{/if}
