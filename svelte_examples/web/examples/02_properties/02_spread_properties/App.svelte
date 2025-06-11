<script>
  import 'Info.svelte';

  var pkg = <Symbol, Object>{
    #name: 'svelte',
    #version: 3,
    #speed: 'blazing',
    #website: Uri.parse('https://svelte.dev'),
  };
</script>

<Info {...pkg} />