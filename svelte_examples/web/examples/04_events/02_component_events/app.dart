import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

import 'inner.dart';

base class App implements Component {
  App();

  @override
  void create(Node anchor) {
    void handleMessage({required String text}) {
      window.alert(text);
    }

    Inner(onMessage: handleMessage).create(anchor);
  }
}
