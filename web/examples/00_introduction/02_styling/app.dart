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
  late Element p;

  return Fragment(
    create: () {
      p = element('p');
      setText(p, 'Styled!');
      setAttribute(p, 'class', 'svelte-urs9w7');
    },
    mount: (target, anchor) {
      insert(target, p, anchor);
    },
    detach: (detaching) {
      if (detaching) {
        remove(p);
      }
    },
  );
}

class App extends Component {
  App(Options options) {
    init(
      component: this,
      options: options,
      createFragment: createFragment,
      props: <String, int>{},
      appendStyles: addCss,
    );
  }
}
