// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

base class App extends ComponentFactory {
  static final root = $.template<HTMLDivElement>(
    '<div class="svelte-1kuj9kb"> </div>',
  );

  @override
  void create(Node anchor) {
    $.appendStyles(anchor, 'svelte-1kuj9kb', '''
  div {
    width: 100%;
    height: 100%;
  }''');

    var m = $.source<List<int>>(<int>[0, 0]);

    void handleMouseMove(MouseEvent event) {
      m.update((m) {
        m[0] = event.clientX;
        m[1] = event.clientY;
      });
    }

    var div = root();
    var text = $.child<Text>(div);

    $.reset(div);

    $.templateEffect(() {
      $.setText(text, 'The mouse position is ${m()[0]} x ${m()[1]}');
    });

    $.event<MouseEvent>('mousemove', div, handleMouseMove);
    $.append(anchor, div);
  }
}
