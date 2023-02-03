import 'dart:html';

import 'package:svelte/runtime.dart';

String src = '/tutorial/image.gif';
String name = 'Rick Astley';

Fragment createFragment(List<Object?>? values) {
  return AppFragment();
}

class AppFragment extends Fragment {
  late ImageElement img;

  @override
  void create() {
    img = element<ImageElement>('img');
    setAttribute(img, 'src', src);
    setAttribute(img, 'alt', '$name dancing');
  }

  @override
  void mount(target, anchor) {
    insert(target, img, anchor);
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(img);
    }
  }
}

class App extends Component {
  App(Options options) {
    init<App>(
      component: this,
      options: options,
      createFragment: createFragment,
    );
  }
}
