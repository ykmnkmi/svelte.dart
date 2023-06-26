<script>
	external var animals;
</script>

{#each animals as [key, value, ...]}
<p>{key}: {value}</p>
{/each}