import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart' show Element, Node, Text;

import 'nested.dart';

void addCss(Element? target) {
  appendStyles(target, 'svelte-urs9w7', '''
p.svelte-urs9w7 {
  color: purple;
  font-family: 'Comic Sans MS', cursive;
  font-size: 2em;
}''');
}

final class AppFragment extends Fragment {
  AppFragment(List<Object?> instance) {
    nested = Nested();
  }

  late Element p;
  late Text t1;
  late Nested nested;

  bool current = false;

  @override
  void create(List<Object?> instance) {
    p = element('p');
    setText(p, 'These styles...');
    t1 = space();
    createComponent(nested);
    setAttribute(p, 'class', 'svelte-urs9w7');
  }

  @override
  void mount(List<Object?> instance, Element target, Node? anchor) {
    insert(target, p, anchor);
    insert(target, t1, anchor);
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
      remove(t1);
    }

    destroyComponent(nested, detaching);
  }
}

final class App extends Component {
  App({
    super.target,
    super.anchor,
    super.inputs,
    super.hydrate,
    super.intro,
  }) : super(createFragment: AppFragment.new, appendStyles: addCss);
}
