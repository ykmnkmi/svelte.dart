import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart';

import 'custom_button.dart';

base class App extends Component {
  App();

  @override
  void call(Node anchor) {
    void handleClick(Event event) {
      window.alert('clicked');
    }

    CustomButton(onClick: handleClick).call(anchor);
  }
}
