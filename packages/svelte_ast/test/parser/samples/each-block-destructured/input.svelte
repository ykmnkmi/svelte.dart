<script>
	export List<List> animals;
</script>

{#each animals as [key, value, ...]}
<p>{key}: {value}</p>
{/each}