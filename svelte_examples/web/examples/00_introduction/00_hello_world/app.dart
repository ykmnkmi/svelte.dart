// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

base class App extends Component {
  static final root = $.template<HTMLHeadingElement>('<h1></h1>');

  @override
  void call(Node anchor) {
    var name = 'world';

    var h1 = root();

    $.setTextContent(h1, 'Hello $name!');
    $.append(anchor, h1);
  }
}
