// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

import 'nested.dart';

base class App implements Component {
  @override
  void call(Node anchor) {
    Nested(answer: $.DefaultProp<int?>(42)).call(anchor);
  }
}
