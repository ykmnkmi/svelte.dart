// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

base class Inner implements Component {
  static final root = $.template<HTMLButtonElement>(
    '<button>Click to say hello</button>',
  );

  Inner({required this.onMessage});

  Prop<void Function({required String text})> onMessage;

  @override
  void call(Node anchor) {
    $.push();

    void sayHello() {
      onMessage()(text: 'Hello!');
    }

    var button = root();

    $.eventVoid('click', button, sayHello);
    $.append(anchor, button);
    $.pop();
  }
}
