// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

import 'user.dart';

base class App extends ComponentFactory {
  static final root1 = $.template<HTMLButtonElement>(
    '<button>Log out</button>',
  );

  static final root2 = $.template<HTMLButtonElement>('<button>Log in</button>');

  @override
  void create(Node anchor) {
    var user = $.source<User>(User(loggedIn: false));

    void toggle() {
      user.update((user) {
        user.loggedIn = !user.loggedIn;
      });
    }

    var fragment = $.comment();
    var node = $.firstChild<Comment>(fragment);

    {
      void consequent(Node anchor) {
        var button = root1();

        $.event0('click', button, toggle);
        $.append(anchor, button);
      }

      void alternate(Node anchor) {
        var button1 = root2();

        $.event0('click', button1, toggle);
        $.append(anchor, button1);
      }

      $.ifBlock(node, (render) {
        if (user().loggedIn) {
          render(consequent);
        } else {
          render(alternate, false);
        }
      });
    }

    $.append(anchor, fragment);
  }
}
