<script>
	@export
	List animals;
</script>

{#each animals as [key, value, ...rest]}
	<p>{key}: {value}</p>
{/each}
