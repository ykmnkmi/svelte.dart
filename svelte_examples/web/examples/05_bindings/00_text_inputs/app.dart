// ignore: library_prefixes
import 'package:svelte_runtime/src/internal.dart' as $;
import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart';

base class App extends Component {
  static final root = $.template<DocumentFragment>(
    '<input placeholder="enter your name"> <p> </p>',
    1,
  );

  @override
  void call(Node anchor) {
    var name = state<String>('');

    var fragment = root();
    var input = $.firstChild<HTMLInputElement>(fragment);

    $.removeInputDefaults(input);

    var p = $.sibling<HTMLParagraphElement>(input, 2);
    var text = $.child<Text>(p);

    $.reset(p);

    $.templateEffect(() {
      $.setText(text, 'Hello ${name().isEmpty ? 'stranger' : name()}!');
    });

    $.bindValueState<String>(input, name);
    $.append(anchor, fragment);
  }
}
