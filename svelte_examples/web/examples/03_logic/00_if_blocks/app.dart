// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

import 'user.dart';

base class App implements Component {
  static final root1 = $.template<HTMLButtonElement>(
    '<button>Log out</button>',
  );

  static final root2 = $.template<HTMLButtonElement>('<button>Log in</button>');

  static final root = $.template<DocumentFragment>('<!> <!>', 1);

  @override
  void create(Node anchor) {
    var user = $.source<User>(User(loggedIn: false));

    void toggle() {
      user.update((user) {
        user.loggedIn = !user.loggedIn;
      });
    }

    var fragment = root();
    var node = $.firstChild<Comment>(fragment);

    {
      void consequent(Node anchor) {
        var button = root1();

        $.eventVoid('click', button, toggle);
        $.append(anchor, button);
      }

      $.ifBlock(node, (render) {
        if (user().loggedIn) {
          render(consequent);
        }
      });
    }

    var node1 = $.sibling<Comment>(node, 2);

    {
      void consequent1(Node anchor) {
        var button1 = root2();

        $.eventVoid('click', button1, toggle);
        $.append(anchor, button1);
      }

      $.ifBlock(node1, (render) {
        if (!user().loggedIn) {
          render(consequent1);
        }
      });
    }

    $.append(anchor, fragment);
  }
}
