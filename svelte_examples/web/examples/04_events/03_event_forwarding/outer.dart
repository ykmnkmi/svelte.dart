import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

import 'inner.dart';

base class Outer extends Component {
  Outer({required void Function({required String text}) onMessage})
    : _inner = Inner(onMessage: onMessage);

  final Inner _inner;

  void Function({required String text}) get onMessage {
    return _inner.onMessage;
  }

  set onMessage(void Function({required String text}) onMessage) {
    _inner.onMessage = onMessage;
  }

  @override
  void call(Node anchor) {
    _inner.call(anchor);
  }
}
