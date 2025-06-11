// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:web/web.dart';

import 'inner.dart';

base class App extends $.Component {
  App();

  @override
  void call(Node anchor) {
    void handleMessage({required String text}) {
      window.alert(text);
    }

    Inner(onMessage: handleMessage).call(anchor);
  }
}
