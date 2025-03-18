import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart';

import 'outer.dart';

base class App extends Component {
  App();

  @override
  void call(Node anchor) {
    void handleMessage({required String text}) {
      window.alert(text);
    }

    Outer(onMessage: handleMessage).call(anchor);
  }
}
