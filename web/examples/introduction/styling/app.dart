import 'dart:html';

import 'package:svelte/runtime.dart';

void addCss(Element? target) {
  appendStyles(target, 'svelte-urs9w7', '''
p.svelte-urs9w7 {
  color: purple;
  font-family: 'Comic Sans MS', cursive;
  font-size: 2em;
}
''');
}

Fragment createFragment(List<Object?> instance) {
  return AppFragment();
}

class AppFragment extends Fragment {
  late ParagraphElement p;

  @override
  void create() {
    p = element<ParagraphElement>('p');
    setText(p, 'Styled!');
    setAttribute(p, 'class', 'svelte-urs9w7');
  }

  @override
  void mount(Element target, Node? anchor) {
    insert(target, p, anchor);
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(p);
    }
  }
}

class App extends Component {
  App(Options options) {
    init<App>(
      component: this,
      options: options,
      createFragment: createFragment,
      props: <String, int>{},
      appendStyles: addCss,
    );
  }
}
