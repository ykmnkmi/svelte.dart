import 'dart:html';

import 'package:svelte_runtime/svelte_runtime.dart';

Fragment createIfBlock1(List<Object?> instance) {
  late Element p;

  return Fragment(
    create: () {
      p = element('p');
      setText(p, '$x is greater than 10');
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

Fragment createIfBlock2(List<Object?> instance) {
  late Element p;

  return Fragment(
    create: () {
      p = element('p');
      setText(p, '$x is less than 5');
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

Fragment createElseBlock(List<Object?> instance) {
  late Element p;

  return Fragment(
    create: () {
      p = element('p');
      setText(p, '$x is between 5 and 10');
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

Fragment createFragment(List<Object?> instance) {
  late Node ifBlockAnchor;

  FragmentFactory selectCurrentBlock(
    List<Object?> context,
    List<int> dirty,
  ) {
    if (x > 10) {
      return createIfBlock1;
    }

    if (5 > x) {
      return createIfBlock2;
    }

    return createElseBlock;
  }

  var currentBlockFactory = selectCurrentBlock(instance, const <int>[-1]);
  var ifBlock = currentBlockFactory(instance);

  return Fragment(
    create: () {
      ifBlock.create();
      ifBlockAnchor = empty();
    },
    mount: (Element target, Node? anchor) {
      ifBlock.mount(target, anchor);
      insert(target, ifBlockAnchor, anchor);
    },
    update: (List<Object?> instance, List<int> dirty) {
      var newBlockFactory = selectCurrentBlock(instance, dirty);

      if (currentBlockFactory == newBlockFactory) {
        ifBlock.update(instance, dirty);
      } else {
        ifBlock.detach(true);

        ifBlock = newBlockFactory(instance)
          ..create()
          ..mount(ifBlockAnchor.parent as Element, ifBlockAnchor);

        currentBlockFactory = newBlockFactory;
      }
    },
    detach: (bool detaching) {
      ifBlock.detach(detaching);

      if (detaching) {
        detach(ifBlockAnchor);
      }
    },
  );
}

var x = 7;

final class App extends Component {
  App({
    super.target,
    super.anchor,
    super.props,
    super.hydrate,
    super.intro,
  }) : super(createFragment: createFragment);
}
