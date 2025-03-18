// ignore: library_prefixes
import 'package:svelte_runtime/src/internal.dart' as $;
import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart';

base class App extends Component {
  static final root1 = $.template<HTMLParagraphElement>('<p></p>');

  static final root3 = $.template<HTMLParagraphElement>('<p></p>');

  static final root4 = $.template<HTMLParagraphElement>('<p></p>');

  App();

  @override
  void call(Node anchor) {
    var x = 7;

    var fragment = $.comment();
    var node = $.firstChild<Comment>(fragment);

    {
      void consequent(Node anchor) {
        var p = root1();

        $.setTextContent(p, '''
$x is greater than 10''');
        $.append(anchor, p);
      }

      void alternate1(Node anchor) {
        var fragment1 = $.comment();
        var node1 = $.firstChild<Comment>(fragment1);

        void consequent1(Node anchor) {
          var p1 = root3();

          $.setTextContent(p1, '''
$x is less than 5''');
          $.append(anchor, p1);
        }

        void alternate(Node anchor) {
          var p2 = root4();

          $.setTextContent(p2, '''
$x is between 5 and 10''');
          $.append(anchor, p2);
        }

        $.ifBlock(node1, (render) {
          if (x > 10) {
            render(consequent1);
          } else {
            render(alternate, false);
          }
        }, true);

        $.append(anchor, fragment1);
      }

      $.ifBlock(node, (render) {
        if (x > 10) {
          render(consequent);
        } else {
          render(alternate1, false);
        }
      });
    }

    $.append(anchor, fragment);
  }
}
