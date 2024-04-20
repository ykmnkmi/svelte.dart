<script type="application/dart">
	import 'Info.svelte';

	var pkg = <String, Object>{
		'name': 'svelte',
		'version': 3,
		'speed': 'blazing',
		'website': 'https://svelte.dev'
	};
</script>

<Info {...pkg} />