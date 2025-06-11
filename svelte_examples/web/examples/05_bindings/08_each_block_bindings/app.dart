// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:web/web.dart';

import 'todo.dart';

base class App extends $.Component {
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

    var todos = $.source<List<ToDo>>([
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

    var remaining = $.derived<int>(() {
      var remaining = todos().where((todo) => !todo.done);
      return remaining.length;
    });

    var fragment = root();
    var node = $.sibling<Comment>($.firstChild(fragment), 2);

    $.eachBlock<ToDo>(node, 17, todos.call, $.index, (anchor, todo, i) {
      var div = root1();
      var input = $.child<HTMLInputElement>(div);

      $.removeInputDefaults(input);

      var input1 = $.sibling<HTMLInputElement>(input, 2);

      $.removeInputDefaults(input1);

      $.reset(div);

      $.templateEffect(() {
        input1.disabled = todo().done;
      });

      $.bindChecked(input, () => todo().done, (value) {
        todo.update((todo) {
          todo.done = value;
        });
      });

      $.bindValue(input1, () => todo().text, (value) {
        todo.update((todo) {
          todo.text = value as String;
        });
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

    $.event0('click', button, add);
    $.event0('click', button1, clear);
    $.append(anchor, fragment);
    $.pop();
  }
}
