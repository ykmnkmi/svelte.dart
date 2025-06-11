// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:web/web.dart';

base class Nested extends $.Component {
  static final root = $.template<HTMLParagraphElement>('<p> </p>');

  Nested({this.answer});

  int? answer;

  @override
  void call(Node anchor) {
    var p = root();
    var text = $.child<Text>(p);

    $.reset(p);

    $.templateEffect(() {
      $.setText(text, 'The answer is ${answer ?? ""}');
    });

    $.append(anchor, p);
  }
}
