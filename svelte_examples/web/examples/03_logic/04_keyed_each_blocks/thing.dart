// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

base class Thing implements Component {
  static final root = $.template<HTMLParagraphElement>(
    '<p><span class="svelte-671r1c">initial</span> <span class="svelte-671r1c">current</span></p>',
  );

  Thing({this.current});

  String? current;

  @override
  void create(Node anchor) {
    $.appendStyles(anchor, 'svelte-671r1c', '''
  span.svelte-671r1c {
    display: inline-block;
    padding: 0.2em 0.5em;
    margin: 0 0.2em 0.2em 0;
    width: 4em;
    text-align: center;
    border-radius: 0.2em;
    color: white;
  }''');

    var initial = current;

    var p = root();
    var span = $.child<HTMLSpanElement>(p);

    $.setAttribute(span, 'style', 'background-color: ${initial ?? ""}');

    var span1 = $.sibling<HTMLSpanElement>(span, 2);

    $.reset(p);

    $.templateEffect(() {
      $.setAttribute(span1, 'style', 'background-color: $current');
    });

    $.append(anchor, p);
  }
}
