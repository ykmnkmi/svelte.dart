import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

import 'nested.dart';

base class App implements Component {
  @override
  void create(Node anchor) {
    Nested(answer: 42).create(anchor);
  }
}
