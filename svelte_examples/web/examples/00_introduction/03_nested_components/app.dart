// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

import 'nested.dart';

base class App extends ComponentFactory {
  static final root = $.template<DocumentFragment>(
    '<p class="svelte-urs9w7">These styles...</p> <!>',
    1,
  );

  @override
  void create(Node anchor) {
    $.appendStyles(anchor, 'svelte-urs9w7', """
  p.svelte-urs9w7 {
    color: purple;
    font-family: 'Comic Sans MS', cursive;
    font-size: 2em;
  }""");

    var fragment = root();
    var node = $.sibling<Comment>($.firstChild(fragment), 2);

    Nested().create(node);
    $.append(anchor, fragment);
  }
}
