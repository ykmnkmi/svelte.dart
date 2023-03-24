import 'dart:html';

import 'package:svelte/runtime.dart';

import 'nested.dart';

void addCss(Element? target) {
  appendStyles(target, 'svelte-urs9w7', '''
p.svelte-urs9w7 {
  color: purple;
  font-family: 'Comic Sans MS', cursive;
  font-size: 2em;
}''');
}

Fragment createFragment(List<Object?> instance) {
  late Element p;
  late Text t1;
  Nested nested;
  var current = false;
  nested = Nested(Options());

  return Fragment(
    create: () {
      p = element('p');
      setText(p, 'These styles...');
      t1 = space();
      createComponent(nested);
      setAttribute(p, 'class', 'svelte-urs9w7');
    },
    mount: (target, anchor) {
      insert(target, p, anchor);
      insert(target, t1, anchor);
      mountComponent(nested, target, anchor);
      current = true;
    },
    intro: (local) {
      if (current) {
        return;
      }

      transitionInComponent(nested, local);
      current = true;
    },
    outro: (local) {
      transitionOutComponent(nested, local);
      current = false;
    },
    detach: (detaching) {
      if (detaching) {
        remove(p);
        remove(t1);
      }

      destroyComponent(nested, detaching);
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
