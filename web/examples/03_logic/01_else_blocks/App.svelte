<script>
	var user = {'loggedIn': false};

	void toggle() {
		user = {'loggedIn': !user['loggedIn']!};
	}
</script>

{#if user.loggedIn}
	<button on:click={toggle}>
		Log out
	</button>
{:else}
	<button on:click={toggle}>
		Log in
	</button>
{/if}