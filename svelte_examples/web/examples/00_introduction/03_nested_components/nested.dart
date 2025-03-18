// ignore: library_prefixes
import 'package:svelte_runtime/src/internal.dart' as $;
import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart';

base class Nested extends Component {
  static final root = $.template<HTMLParagraphElement>(
    "<p>...don't affect this element</p>",
  );

  @override
  void call(Node anchor) {
    var p = root();

    $.append(anchor, p);
  }
}
