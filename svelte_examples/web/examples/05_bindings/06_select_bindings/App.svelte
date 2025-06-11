<script>
  import 'package:svelte/svelte.dart';
  import 'package:web/web.dart';

  var questions = <({int id, String text})>[
    (id: 1, text: 'Where did you go to school?'),
    (id: 2, text: "What is your mother's name?"),
    (id: 3, text: 'What is another personal fact that an attacker could easily find with Google?'),
  ];

  var selected = state<({int id, String text})?>(null);
  var answer = state<String>('');

  void handleSubmit(Event event) {
    event.preventDefault();
    window.alert('Answered question ${selected!.id} ${selected!.text} with "${answer}".');
  }
</script>

<h2>Insecurity questions</h2>

<form onsubmit={handleSubmit}>
  <select bind:value={selected} onchange={() => answer = ''}>
    {#each questions as question}
      <option value={question}>
        {question.text}
      </option>
    {/each}
  </select>

  <input bind:value={answer} />

  <button disabled={!answer} type="submit">Submit</button>
</form>

<p>selected question {selected != null ? selected.id : '[waiting...]'}</p>

<style>
  input {
    display: block;
    width: 500px;
    max-width: 100%;
  }
</style>