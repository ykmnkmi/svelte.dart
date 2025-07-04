import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

import 'custom_button.dart';

base class App implements Component {
  App();

  @override
  void create(Node anchor) {
    void handleClick(Event event) {
      window.alert('clicked');
    }

    CustomButton(onClick: handleClick).create(anchor);
  }
}
