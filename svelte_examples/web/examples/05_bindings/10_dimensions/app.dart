// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

base class App extends ComponentFactory {
  static final root = $.template<DocumentFragment>(
    '<input type="range" class="svelte-1oqthja"> <input class="svelte-1oqthja"> <p> </p> <div class="svelte-1oqthja"><span> </span></div>',
    1,
  );

  @override
  void create(Node anchor) {
    $.appendStyles(anchor, 'svelte-1oqthja', '''
  input.svelte-1oqthja {
    display: block;
  }
  div.svelte-1oqthja {
    display: inline-block;
  }''');

    var w = $.source<int>(0);
    var h = $.source<int>(0);
    var size = $.source<int>(42);
    var text = $.source<String>('edit me');

    var fragment = root();
    var input = $.firstChild<HTMLInputElement>(fragment);

    $.removeInputDefaults(input);

    var input1 = $.sibling<HTMLInputElement>(input, 2);

    $.removeInputDefaults(input);

    var p = $.sibling<HTMLInputElement>(input1, 2);
    var text1 = $.child<Text>(p);

    $.reset(p);

    var div = $.sibling<HTMLDivElement>(p, 2);
    var span = $.child<HTMLSpanElement>(div);
    var text2 = $.child<Text>(span);

    $.reset(span);
    $.reset(div);

    $.templateEffect(() {
      $.setText(text1, 'size: ${w()}px x ${h()}px');
      $.setAttribute(span, 'style', 'font-size: ${size()}px');
      $.setText(text2, text());
    });

    $.bindValue(input, size.call, (value) {
      size.set(value as int);
    });

    $.bindValue(input1, text.call, (value) {
      text.set(value as String);
    });

    $.bindElementSize(div, 'clientWidth', w.set);
    $.bindElementSize(div, 'clientHeight', h.set);
    $.append(anchor, fragment);
  }
}
