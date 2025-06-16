// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

base class App extends ComponentFactory {
  static final root1 = $.template<HTMLLIElement>(
    '<li><a target="_blank" rel="noreferrer"> </a></li>',
  );
  static final root = $.template<DocumentFragment>(
    '<h1>The Famous Cats of YouTube</h1> <ul></ul>',
    1,
  );

  @override
  void create(Node anchor) {
    var cats = [
      (id: 'J---aiyznGQ', name: 'Keyboard Cat'),
      (id: 'z_AbfPXTKms', name: 'Maru'),
      (id: 'OUtn3pvWmpg', name: 'Henri The Existential Cat'),
    ];

    var fragment = root();
    var ul = $.sibling<HTMLUListElement>($.firstChild(fragment), 2);

    $.eachBlock(ul, 21, () => cats, $.index, (anchor, item, i) {
      String id() {
        return item().id;
      }

      String name() {
        return item().name;
      }

      var li = root1();
      var a = $.child<HTMLAnchorElement>(li);
      var text = $.child<Text>(a);

      $.reset(a);
      $.reset(li);

      $.templateEffect(() {
        $.setAttribute(a, 'href', 'https://www.youtube.com/watch?v=${id()}');
        $.setText(text, '${i + 1}: ${name()}');
      });

      $.append(anchor, li);
    });

    $.reset(ul);
    $.append(anchor, fragment);
  }
}
