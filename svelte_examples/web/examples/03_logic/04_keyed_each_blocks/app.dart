// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:web/web.dart';

import 'thing.dart';

base class _Thing extends Thing {
  _Thing({required this.current_});

  String? Function() current_;

  @override
  String? get current {
    return current_();
  }

  @override
  set current(String? current) {
    current_ = () {
      return current;
    };
  }
}

base class App extends $.Component {
  static final root = $.template<DocumentFragment>(
    '<button>Remove first thing</button> <div style="display: grid; grid-template-columns: 1fr 1fr; grid-gap: 1em"><div><h2>Keyed</h2> <!> </div> <div><h2>Unkeyed</h2> <!></div></div>',
    1,
  );

  @override
  void call(Node anchor) {
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
      _Thing(current_: () => item().color).call(anchor);
    });

    $.reset(div1);

    var div2 = $.sibling<HTMLDivElement>(div1, 2);
    var node1 = $.sibling<Comment>($.child(div2), 2);

    $.eachBlock(node1, 17, () => things(), $.index, (anchor, item, i) {
      _Thing(current_: () => item().color).call(anchor);
    });

    $.reset(div2);
    $.reset(div);
    $.event0('click', button, handleClick);
    $.append(anchor, fragment);
  }
}
