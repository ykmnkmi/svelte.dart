{#each people as People(:name, :cool)}
  <p>{name} is {cool ? 'cool' : 'not cool'}</p>
{/each}