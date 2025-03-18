// ignore: library_prefixes
import 'package:svelte_runtime/src/internal.dart' as $;
import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart';

base class App extends Component {
  static final root = $.template<HTMLParagraphElement>('<p><!></p>');

  @override
  void call(Node anchor) {
    var string = "here's some <strong>HTML!!!</strong>";

    var p = root();
    var node = $.child<Comment>(p);

    $.html(node, () => string, false, false);
    $.reset(p);
    $.append(anchor, p);
  }
}
