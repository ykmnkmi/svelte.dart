import 'dart:html';

import 'package:svelte/runtime.dart';

import 'nested.dart';

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
  AppFragment() {
    nested = Nested(Options());
  }

  late Element p;

  late Text t;

  late Nested nested;

  late bool current;

  @override
  void create() {
    p = element('p');
    setText(p, 'These styles...');
    t = space();
    createComponent(nested);
    setAttribute(p, 'class', 'svelte-urs9w7');
  }

  @override
  void mount(Element target, Node? anchor) {
    insert(target, p, anchor);
    insert(target, t, anchor);
    mountComponent(nested, target, anchor);
    current = true;
  }

  @override
  void intro(bool local) {
    if (current) {
      return;
    }

    transitionInComponent(nested, local);
    current = true;
  }

  @override
  void outro(bool local) {
    transitionOutComponent(nested, local);
    current = false;
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(p);
      remove(t);
    }

    destroyComponent(nested, detaching);
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
