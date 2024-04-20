<script type="application/dart">
	import 'dart:html';

	var count = 0;

	$: if (count >= 10) {
		window.alert(`count is dangerously high!`);
		count = 9;
	}

	void handleClick() {
		count += 1;
	}
</script>

<button on:click={handleClick}>
	Clicked {count} {count === 1 ? 'time' : 'times'}
</button>