<script type="application/dart">
  import 'package:svelte_runtime/svelte_runtime.dart';

  var todos = state<List<ToDo>>(<ToDo>[
    ToDo(done: false, text: 'finish Svelte tutorial'),
    ToDo(done: false, text: 'build an app'),
    ToDo(done: false, text: 'world domination'),
  ]);

  void add() {
    todos.set(<ToDo>[...todos(), ToDo(done: false, text: '')]);
  }

  void clear() {
    todos.set(todos().where((todo) => !todo.done).toList());
  }

  var remaining = derived<int>(() {
    var remaining = todos().where((todo) => !todo.done);
    return remaining.length;
  });
</script>

<h1>Todos</h1>

{#each todos() as todo}
  <div>
    <input type="checkbox" bind:checked={todo.done} />

    <input placeholder="What needs to be done?" bind:value={todo.text} disabled={todo.done} />
  </div>
{/each}

<p>{remaining} remaining</p>

<button onclick={add}>Add new</button>

<button onclick={clear}>Clear completed</button>