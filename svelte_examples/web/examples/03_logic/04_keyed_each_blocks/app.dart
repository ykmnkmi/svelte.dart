// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

import 'thing.dart';

base class _Thing extends Thing {
  _Thing(this._current);

  final String Function() _current;

  @override
  String? get current {
    return _current();
  }
}

base class App implements Component {
  static final root = $.template<DocumentFragment>(
    '<button>Remove first thing</button> <div style="display: grid; grid-template-columns: 1fr 1fr; grid-gap: 1em"><div><h2>Keyed</h2> <!> </div> <div><h2>Unkeyed</h2> <!></div></div>',
    1,
  );

  @override
  void create(Node anchor) {
    var things = $.source<List<({String color, int id})>>([
      (id: 1, color: 'darkblue'),
      (id: 2, color: 'indigo'),
      (id: 3, color: 'deeppink'),
      (id: 4, color: 'salmon'),
      (id: 5, color: 'gold'),
    ]);

    void handleClick() {
      things.update((things) {
        things.removeAt(0);
      });
    }

    var fragment = root();
    var button = $.firstChild<HTMLButtonElement>(fragment);

    var div = $.sibling<HTMLDivElement>(button, 2);
    var div1 = $.child<HTMLDivElement>(div);
    var node = $.sibling<Comment>($.child(div1), 2);

    $.eachBlock(node, 17, () => things(), (thing, index) => thing.id, (
      anchor,
      item,
      i,
    ) {
      _Thing(() => item().color).create(anchor);
    });

    $.reset(div1);

    var div2 = $.sibling<HTMLDivElement>(div1, 2);
    var node1 = $.sibling<Comment>($.child(div2), 2);

    $.eachBlock(node1, 17, () => things(), $.index, (anchor, item, i) {
      _Thing(() => item().color).create(anchor);
    });

    $.reset(div2);
    $.reset(div);
    $.eventVoid('click', button, handleClick);
    $.append(anchor, fragment);
  }
}
