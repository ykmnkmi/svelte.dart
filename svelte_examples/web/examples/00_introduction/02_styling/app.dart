import 'dart:html';

import 'package:svelte_runtime/svelte_runtime.dart';

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
    mount: (Element target, Node? anchor) {
      insert(target, p, anchor);
    },
    detach: (bool detaching) {
      if (detaching) {
        detach(p);
      }
    },
  );
}

final class App extends Component {
  App({
    super.target,
    super.anchor,
    super.props,
    super.hydrate,
    super.intro,
  }) : super(createFragment: createFragment, appendStyles: addCss);
}
