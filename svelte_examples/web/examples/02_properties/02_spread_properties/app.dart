// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

base class App implements Component {
  static final root = $.template<HTMLParagraphElement>(
    '<p>No spread support!</p>',
  );

  @override
  void call(Node anchor) {
    var p = root();

    $.append(anchor, p);
  }
}
