// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

base class Nested implements Component {
  static final root = $.template<HTMLParagraphElement>(
    "<p>...don't affect this element</p>",
  );

  @override
  void create(Node anchor) {
    var p = root();

    $.append(anchor, p);
  }
}
