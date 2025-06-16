import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

import 'outer.dart';

base class App extends ComponentFactory {
  App();

  @override
  void create(Node anchor) {
    void handleMessage({required String text}) {
      window.alert(text);
    }

    Outer(onMessage: handleMessage).create(anchor);
  }
}
