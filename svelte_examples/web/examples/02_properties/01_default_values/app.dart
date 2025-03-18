// ignore: library_prefixes
import 'package:svelte_runtime/src/internal.dart' as $;
import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart';

import 'nested.dart';

base class App extends Component {
  static final root = $.template('<!> <!>', 1);

  @override
  void call(Node anchor) {
    var fragment = root() as DocumentFragment;
    var node = $.firstChild<Comment>(fragment);

    Nested(answer: 42).call(node);

    var node1 = $.sibling<Comment>(node, 2);

    Nested().call(node1);
    $.append(anchor, fragment);
  }
}
