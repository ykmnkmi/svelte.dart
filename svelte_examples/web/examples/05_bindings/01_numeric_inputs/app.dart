// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

base class App implements Component {
  static final root = $.template<DocumentFragment>(
    '<label><input type="number" min="0" max="10"> <input type="range" min="0" max="10"></label> <label><input type="number" min="0" max="10"> <input type="range" min="0" max="10"></label> <p> </p>',
    1,
  );

  @override
  void create(Node anchor) {
    var a = $.source<int>(0);
    var b = $.source<int>(0);

    var fragment = root();
    var label = $.firstChild<HTMLLabelElement>(fragment);
    var input = $.child<HTMLInputElement>(label);

    $.removeInputDefaults(input);

    var input1 = $.sibling<HTMLInputElement>(input, 2);

    $.removeInputDefaults(input1);
    $.reset(label);

    var label1 = $.sibling<HTMLLabelElement>(label, 2);
    var input2 = $.child<HTMLInputElement>(label1);

    $.removeInputDefaults(input2);

    var input3 = $.sibling<HTMLInputElement>(input2, 2);

    $.removeInputDefaults(input3);
    $.reset(label1);

    var p = $.sibling<HTMLParagraphElement>(label1, 2);
    var text = $.child<Text>(p);

    $.reset(p);

    $.templateEffect(() {
      $.setText(text, '${a()} + ${b()} = ${a() + b()}');
    });

    $.bindValue(input, a.call, (value) {
      a.set(value as int);
    });

    $.bindValue(input1, a.call, (value) {
      a.set(value as int);
    });

    $.bindValue(input2, b.call, (value) {
      b.set(value as int);
    });

    $.bindValue(input3, b.call, (value) {
      b.set(value as int);
    });

    $.append(anchor, fragment);
  }
}
