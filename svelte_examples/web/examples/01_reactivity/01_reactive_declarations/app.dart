// ignore: library_prefixes
import 'package:svelte_runtime/src/internal.dart' as $;
import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart';

base class App extends Component {
  static final root = $.template<DocumentFragment>(
    '<button> </button> <p> </p> <p> </p>',
    1,
  );

  @override
  void call(Node anchor) {
    var count = state<int>(0);
    var doubled = derived<int>(() => count() * 2);
    var quadrupled = derived<int>(() => doubled() * 2);

    void handleClick() {
      count.set(count() + 1);
    }

    var fragment = root();
    var button = $.firstChild<HTMLButtonElement>(fragment);
    var text = $.child<Text>(button);

    $.reset(button);

    var p = $.sibling<HTMLParagraphElement>(button, 2);
    var text1 = $.child<Text>(p);

    $.reset(p);

    var p1 = $.sibling<HTMLParagraphElement>(p, 2);
    var text2 = $.child<Text>(p1);

    $.reset(p1);

    $.templateEffect(() {
      $.setText(text, 'Count: ${count()}');
      $.setText(text1, '${count()} * 2 = ${doubled()}');
      $.setText(text2, '${doubled()} * 2 = ${quadrupled()}');
    });

    $.event0('click', button, handleClick);
    $.append(anchor, fragment);
  }
}
