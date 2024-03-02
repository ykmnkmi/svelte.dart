<script>
	import 'Info.svelte';

	var properties = InfoProperties(
		name: 'svelte',
		version: 3,
		speed: 'blazing',
		website: 'https://svelte.dev'
	);
  
</script>

<Info {...properties} />