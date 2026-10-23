// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

import 'todo.dart';

base class App implements Component {
  static final root1 = $.template<HTMLDivElement>(
    '<div><input type="checkbox"> <input placeholder="What needs to be done?"></div>',
  );
  static final root = $.template<DocumentFragment>(
    '<h1>Todos</h1> <!> <p> </p> <button>Add new</button> <button>Clear completed</button>',
    1,
  );

  @override
  void call(Node anchor) {
    $.push();

    var tasks = state<List<Task>>([
      Task('finish Svelte tutorial', false),
      Task('build an app', false),
      Task('world domination', false),
    ]);

    void add() {
      tasks.set(<Task>[...tasks(), Task('', false)]);
    }

    void clear() {
      tasks.set(tasks().where((task) => !task.done()).toList());
    }

    var remaining = derived<int>(() {
      var remaining = tasks().where((task) => !task.done());
      return remaining.length;
    });

    var fragment = root();
    var node = $.sibling<Comment>($.firstChild(fragment), 2);

    $.eachBlock<Task>(node, 17, tasks.call, $.index, (anchor, task, i) {
      var div = root1();
      var input = $.child<HTMLInputElement>(div);

      $.removeInputDefaults(input);

      var input1 = $.sibling<HTMLInputElement>(input, 2);

      $.removeInputDefaults(input1);

      $.reset(div);

      $.templateEffect(() {
        input1.disabled = task().done();
      });

      $.bindChecked(input, () => task().done(), (value) {
        task().done.set(value);
      });

      $.bindValue(input1, () => task().text(), (value) {
        task().text.set(value as String);
      });

      $.append(anchor, div);
    });

    var p = $.sibling<HTMLParagraphElement>(node, 2);
    var text = $.child<Text>(p);

    $.reset(p);

    var button = $.sibling<HTMLButtonElement>(p, 2);
    var button1 = $.sibling<HTMLButtonElement>(button, 2);

    $.templateEffect(() {
      $.setText(text, '${remaining()} remaining');
    });

    $.eventVoid('click', button, add);
    $.eventVoid('click', button1, clear);
    $.append(anchor, fragment);
    $.pop();
  }
}
