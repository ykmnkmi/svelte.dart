// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

base class App implements Component {
  static final root1 = $.template<HTMLParagraphElement>(
    '<p>Thank you. We will bombard your inbox and sell your personal details.</p>',
  );
  static final root2 = $.template<HTMLParagraphElement>(
    "<p>You must opt-in to continue. If you're not paying, you're the product.</p>",
  );
  static final root = $.template<DocumentFragment>(
    '<label><input type="checkbox"> Yes! Send me regular email spam</label> <!> <button>Subscribe</button>',
    1,
  );

  @override
  void create(Node anchor) {
    var yes = $.source<bool>(false);

    var fragment = root();
    var label = $.firstChild<HTMLLabelElement>(fragment);
    var input = $.child<HTMLInputElement>(label);

    $.removeInputDefaults(input);
    $.next();
    $.reset(label);

    var node = $.sibling<Comment>(label, 2);

    {
      void consequent(Node anchor) {
        var p = root1();

        $.append(anchor, p);
      }

      void alternate(Node anchor) {
        var p1 = root2();

        $.append(anchor, p1);
      }

      $.ifBlock(node, (render) {
        if (yes()) {
          render(consequent);
        } else {
          render(alternate, false);
        }
      });
    }

    var button = $.sibling<HTMLButtonElement>(node, 2);

    $.templateEffect(() {
      button.disabled = !yes();
    });

    $.bindChecked(input, yes.call, yes.set);
    $.append(anchor, fragment);
  }
}
