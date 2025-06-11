<script>
  import 'package:svelte/svelte.dart';
  import 'package:web/web.dart';

  var files = state<FileList?>(null);

  effect<void>(() {
    if (files != null) {
      // Note that `files` is of type `FileList`, not an Array:
      // https://developer.mozilla.org/en-US/docs/Web/API/FileList
      console.log(files);

      for (var file in JSImmutableListWrapper<FileList, File>(files!)) {
        print('${file.name}: ${file.size} bytes');
      }
    }
  });
</script>

<label for="avatar">Upload a picture:</label>
<input accept="image/png, image/jpeg" bind:files id="avatar" name="avatar" type="file" />

<label for="many">Upload multiple files of any type:</label>
<input bind:files id="many" multiple type="file" />

{#if files != null}
  <h2>Selected files:</h2>
  {#each JSImmutableListWrapper<FileList, File>(files!) as file}
    <p>{file.name} ({file.size} bytes)</p>
  {/each}
{/if}