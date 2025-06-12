// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

base class Info extends Component {
  static final root = $.template<HTMLParagraphElement>(
    '<p>The <code> </code> <a>npm</a> and <a>learn more here</a>.</p>',
  );

  Info({
    required this.name,
    required this.version,
    required this.speed,
    required this.website,
  });

  String name;

  int version;

  String speed;

  Uri website;

  @override
  void call(Node anchor) {
    var p = root();
    var code = $.sibling<HTMLElement>($.child(p));
    var text = $.child<Text>(code, true);

    $.reset(code);

    var text1 = $.sibling<Text>(code);
    var a = $.sibling<HTMLAnchorElement>(text1);
    var a1 = $.sibling<HTMLAnchorElement>(a, 2);

    $.reset(p);

    $.templateEffect(() {
      $.setText(text, name);
      $.setText(
        text1,
        'package is $speed fast. Download version $version from ',
      );
      $.setAttribute(a, 'href', 'https://www.npmjs.com/package/name');
      $.setAttribute(a1, 'href', '$website');
    });

    $.append(anchor, p);
  }
}
