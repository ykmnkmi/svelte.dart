<script type="text/x-dart">
  import 'package:svelte/svelte.dart';

  var tasks = state<List<Task>>([
    Task('finish Svelte tutorial', false),
    Task('build an app', false),
    Task('world domination', false),
  ]);

  void add() {
    tasks = <Task>[...tasks(), Task('', false)];
  }

  void clear() {
    tasks = tasks.where((task) => !task.done()).toList();
  }

  var remaining = derivedBy<int>(() {
    var remaining = tasks().where((task) => !task.done());
    return remaining.length;
  });
</script>

<h1>Todos</h1>

{#each tasks as task}
  <div>
    <input type="checkbox" bind:checked={task().done} />
    <input placeholder="What needs to be done?" bind:value={task().text} disabled={task().done()} />
  </div>
{/each}

<p>{remaining} remaining</p>

<button onclick={add}>Add new</button>

<button onclick={clear}>Clear completed</button>