import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

import 'nested.dart';

base class App extends Component {
  @override
  void call(Node anchor) {
    Nested(answer: 42).call(anchor);
  }
}
