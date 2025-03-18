// ignore: library_prefixes
import 'package:svelte_runtime/src/internal.dart' as $;
import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart';

base class App extends Component {
  static final root = $.template<DocumentFragment>(
    '<label><input type="number" min="0" max="10"> <input type="range" min="0" max="10"></label> <label><input type="number" min="0" max="10"> <input type="range" min="0" max="10"></label> <p> </p>',
    1,
  );

  @override
  void call(Node anchor) {
    var a = state<int>(0);
    var b = state<int>(0);

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

    $.bindValueState<int>(input, a);
    $.bindValueState<int>(input1, a);
    $.bindValueState<int>(input2, b);
    $.bindValueState<int>(input3, b);
    $.append(anchor, fragment);
  }
}
