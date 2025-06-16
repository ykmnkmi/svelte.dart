// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

base class Nested extends ComponentFactory {
  static final root = $.template<HTMLParagraphElement>('<p> </p>');

  Nested({this.answer = 'a mystery'});

  Object answer;

  @override
  void create(Node anchor) {
    var p = root();
    var text = $.child<Text>(p);

    $.reset(p);

    $.templateEffect(() {
      $.setText(text, 'The answer is $answer');
    });

    $.append(anchor, p);
  }
}
