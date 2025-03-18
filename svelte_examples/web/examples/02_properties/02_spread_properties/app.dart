import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart';

import 'info.dart';

base class App extends Component {
  @override
  void call(Node anchor) {
    var pkg = <Symbol, Object?>{
      #name: 'svelte',
      #version: 5,
      #speed: 'blazing',
      #website: Uri.parse('https://svelte.dev'),
    };

    (Function.apply(Info.new, const <Never>[], pkg) as Info).call(anchor);
  }
}
