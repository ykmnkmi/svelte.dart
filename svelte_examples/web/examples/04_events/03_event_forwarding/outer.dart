import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

import 'inner.dart';

base class Outer implements Component {
  Outer({required this.onMessage});

  Prop<void Function({required String text})> onMessage;

  @override
  void call(Node anchor) {
    Inner(onMessage: onMessage).call(anchor);
  }
}
