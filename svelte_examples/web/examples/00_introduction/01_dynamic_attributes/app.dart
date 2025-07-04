// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

base class App implements Component {
  static final root = $.template<HTMLImageElement>('<img>');

  @override
  void create(Node anchor) {
    var src = '/tutorial/image.gif';
    var name = 'Rick Astley';

    var img = root();

    $.setAttribute(img, 'src', src);
    $.setAttribute(img, 'alt', '$name dancing');
    $.append(anchor, img);
  }
}
