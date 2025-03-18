// ignore: library_prefixes
import 'package:svelte_runtime/src/internal.dart' as $;
import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart';

base class App extends Component {
  static final root = $.template<HTMLButtonElement>('<button> </button>');

  @override
  void call(Node anchor) {
    var count = state<int>(0);

    void handleClick() {
      count.set(count() + 1);
    }

    var button = root();
    var text = $.child<Text>(button);

    $.reset(button);

    $.templateEffect(() {
      $.setText(text, 'Clicked ${count()} ${count() == 1 ? 'time' : 'times'}');
    });

    $.event0('click', button, handleClick);
    $.append(anchor, button);
  }
}
