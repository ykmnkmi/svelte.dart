// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

import 'nested.dart';

base class App extends ComponentFactory {
  static final root = $.template<DocumentFragment>('<!> <!>', 1);

  @override
  void create(Node anchor) {
    var fragment = root();
    var node = $.firstChild<Comment>(fragment);

    Nested(answer: 42).create(node);

    var node1 = $.sibling<Comment>(node, 2);

    Nested().create(node1);
    $.append(anchor, fragment);
  }
}
