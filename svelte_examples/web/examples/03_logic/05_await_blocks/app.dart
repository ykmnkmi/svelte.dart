import 'dart:math';

import 'package:svelte_runtime/svelte_runtime.dart';
// ignore: library_prefixes
import 'package:svelte_runtime/src/internal.dart' as $;
import 'package:web/web.dart';

base class App extends Component {
  static final root1 = $.template<HTMLParagraphElement>('<p> </p>');

  static final root2 = $.template<HTMLParagraphElement>(
    '<p style="color: red"> </p>',
  );

  static final root3 = $.template<HTMLParagraphElement>('<p>...waiting</p>');

  static final root = $.template<DocumentFragment>(
    '<button>generate random number</button> <!>',
    1,
  );

  @override
  void call(Node anchor) {
    $.push();

    Future<int> getRandomNumber() {
      var random = Random();

      if (random.nextBool()) {
        return Future<int>.value(random.nextInt(0xFF));
      }

      return Future<int>.error(StateError('No luck!'));
    }

    var future = state<Future<int>>(getRandomNumber());

    void handleClick() {
      future.set(getRandomNumber());
    }

    var fragment = root();
    var button = $.firstChild<HTMLButtonElement>(fragment);
    var node = $.sibling(button, 2);

    $.awaitBlock(
      node,
      () {
        return future();
      },
      (anchor) {
        var p2 = root3();

        $.append(anchor, p2);
      },
      (anchor, number) {
        var p = root1();
        var text1 = $.child<Text>(p);

        $.reset(p);

        $.templateEffect(() {
          $.setText(text1, 'The number is ${number()}');
        });

        $.append(anchor, p);
      },
      (anchor, error) {
        var p1 = root2();
        var text2 = $.child<Text>(p1, true);

        $.reset(p1);

        $.templateEffect(() {
          $.setText(text2, '${error()}');
        });

        $.append(anchor, p1);
      },
    );

    $.event0('click', button, handleClick);
    $.append(anchor, fragment);
    $.pop();
  }
}
