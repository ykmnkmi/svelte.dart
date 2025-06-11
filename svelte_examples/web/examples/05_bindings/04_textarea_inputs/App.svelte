<script>
  import 'package:markdown/markdown.dart' show markdownToHtml;
  import 'package:svelte/svelte.dart';  
  
  var text = state<String>('Some words are *italic*, some are **bold**');
</script>

<textarea bind:value={text}></textarea>

{@html markdownToHtml(text, inlineOnly: true)}

<style>
  textarea {
    width: 100%;
    height: 200px;
  }
</style>