<script>
	var count = 1;

	// the `$:` means 're-run whenever these values change'
	//
	$: doubled = count * 2;
	$: quadrupled = doubled * 2;

	void handleClick() {
		count += 1;
	}
</script>

<button on:click={handleClick}>
	Clicked {count} {count === 1 ? 'time' : 'times'}
</button>