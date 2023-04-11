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
        detach(p);
      }
    },
  );
}

class App extends Component {
  App({
    Element? target,
    Node? anchor,
    Map<String, Object?>? props,
    bool hydrate = false,
    bool intro = false,
  }) {
    init(
      component: this,
      options: (
        target: target,
        anchor: anchor,
        props: props,
        hydrate: hydrate,
        intro: intro,
      ),
      createFragment: createFragment,
      appendStyles: addCss,
    );
  }
}
