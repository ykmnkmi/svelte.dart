// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

import 'keypad.dart';

base class App implements Component {
  static final root = $.template<DocumentFragment>(
    '<h1 class="svelte-3f6qiv"> </h1> <!>',
    1,
  );

  @override
  void call(Node anchor) {
    $.appendStyles(anchor, 'svelte-3f6qiv', '''
  h1.svelte-3f6qiv {
    color:#ccc;
  }

  h1.pin.svelte-3f6qiv {
    color:#333;
  }

  body.dark h1.svelte-3f6qiv {
    color:#444;
  }

  body.dark h1.pin.svelte-3f6qiv {
    color:#fff;
  }''');

    var pin = state('');
    var view = derived(
      () => pin().isNotEmpty
          ? pin().replaceAll(RegExp('\\d(?!\$)'), '•')
          : 'enter your pin',
    );

    void handleSubmit() {
      window.alert('submitted ${pin()}');
    }

    var fragment = root();
    var h1 = $.firstChild<HTMLHeadingElement>(fragment);
    var text = $.child<Text>(h1, true);

    $.reset(h1);

    var node = $.sibling<Comment>(h1, 2);

    Keypad(
      value: $.BindableProp(pin.call, pin.set),
      onSubmit: $.DefaultProp<void Function()>(handleSubmit),
    ).call(node);

    $.templateEffect(() {
      $.toggleClass(h1, 'pin', pin().isNotEmpty);
      $.setText(text, view());
    });

    $.append(anchor, fragment);
  }
}
