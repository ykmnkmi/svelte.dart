// ignore: library_prefixes
import 'package:svelte_runtime/src/internal.dart' as $;
import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart';

base class App extends Component {
  static final root = $.template<HTMLDivElement>(
    '<div class="svelte-1c44y5p"> </div>',
  );

  @override
  void call(Node anchor) {
    $.appendStyles(anchor, 'svelte-1c44y5p', '''
  div {
    width: 100%;
    height: 100%;
  }''');

    var m = state<List<int>>(<int>[0, 0]);

    var div = root();
    var text = $.child<Text>(div);

    $.reset(div);

    $.templateEffect(() {
      $.setText(text, 'The mouse position is ${m()[0]} x ${m()[1]}');
    });

    $.event<MouseEvent>('mousemove', div, (MouseEvent event) {
      m.set(<int>[event.clientX, event.clientY]);
    });

    $.append(anchor, div);
  }
}
