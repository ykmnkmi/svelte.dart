// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

base class App extends Component {
  static final root = $.template<HTMLParagraphElement>(
    '<p class="svelte-urs9w7">Styled!</p>',
  );

  @override
  void call(Node anchor) {
    $.appendStyles(anchor, 'svelte-urs9w7', """
  p.svelte-urs9w7 {
    color: purple;
    font-family: 'Comic Sans MS', cursive;
    font-size: 2em;
  }""");

    var p = root();

    $.append(anchor, p);
  }
}
