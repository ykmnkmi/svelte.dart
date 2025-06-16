import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

import 'info.dart';

base class App extends ComponentFactory {
  @override
  void create(Node anchor) {
    var pkg = <Symbol, Object?>{
      #name: 'svelte',
      #version: 5,
      #speed: 'blazing',
      #website: Uri.parse('https://svelte.dev'),
    };

    (Function.apply(Info.new, const <Never>[], pkg) as Info).create(anchor);
  }
}
