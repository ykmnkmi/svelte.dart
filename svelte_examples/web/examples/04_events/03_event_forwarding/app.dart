// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

import 'outer.dart';

base class App implements Component {
  App();

  @override
  void call(Node anchor) {
    void handleMessage({required String text}) {
      window.alert(text);
    }

    Outer(
      onMessage: $.ValueProp<void Function({required String text})>(
        handleMessage,
      ),
    ).call(anchor);
  }
}
