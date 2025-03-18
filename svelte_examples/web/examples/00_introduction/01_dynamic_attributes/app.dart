// ignore: library_prefixes
import 'package:svelte_runtime/src/internal.dart' as $;
import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart';

base class App extends Component {
  static final root = $.template<HTMLImageElement>('<img>');

  @override
  void call(Node anchor) {
    var src = '/tutorial/image.gif';
    var name = 'Rick Astley';

    var img = root();

    $.setAttribute(img, 'src', src);
    $.setAttribute(img, 'alt', '$name dancing');
    $.append(anchor, img);
  }
}
