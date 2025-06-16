// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

base class App extends ComponentFactory {
  static final root = $.template<HTMLParagraphElement>('<p><!></p>');

  @override
  void create(Node anchor) {
    var string = "here's some <strong>HTML!!!</strong>";

    var p = root();
    var node = $.child<Comment>(p);

    $.html(node, () => string, false, false);
    $.reset(p);
    $.append(anchor, p);
  }
}
