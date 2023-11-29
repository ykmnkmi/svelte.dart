<script>
	import 'cat.dart';

	var cats = [
		Cat('J---aiyznGQ', 'Keyboard Cat'),
		Cat('z_AbfPXTKms', 'Maru'),
		Cat('OUtn3pvWmpg', 'Henri The Existential Cat')
	];
</script>

<h1>The Famous Cats of YouTube</h1>

<ul>
	{#each cats as { id, name }, i}
		<li>
			<a target="_blank" rel="noreferrer" href="https://www.youtube.com/watch?v={id}">
				{i + 1}: {name}
			</a>
		</li>
	{/each}
</ul>