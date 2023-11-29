import 'dart:html';

import 'package:svelte_runtime/svelte_runtime.dart';

Fragment createIfBlock1(List<Object?> instance) {
  late Element p;

  return Fragment(
    create: () {
      p = element('p');
      setText(p, '$x is greater than 10');
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

Fragment createIfBlock2(List<Object?> instance) {
  late Element p;

  return Fragment(
    create: () {
      p = element('p');
      setText(p, '$x is less than 5');
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

Fragment createElseBlock(List<Object?> instance) {
  late Element p;

  return Fragment(
    create: () {
      p = element('p');
      setText(p, '$x is between 5 and 10');
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

Fragment createFragment(List<Object?> instance) {
  late Node ifBlockAnchor;

  Fragment Function(List<Object?>) selectCurrentBlock(
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
    mount: (target, anchor) {
      ifBlock.mount(target, anchor);
      insert(target, ifBlockAnchor, anchor);
    },
    update: (context, dirty) {
      var newBlockFactory = selectCurrentBlock(context, dirty);

      if (currentBlockFactory == newBlockFactory) {
        ifBlock.update(context, dirty);
      } else {
        ifBlock.detach(true);

        ifBlock = newBlockFactory(context)
          ..create()
          ..mount(ifBlockAnchor.parent as Element, ifBlockAnchor);

        currentBlockFactory = newBlockFactory;
      }
    },
    detach: (detaching) {
      ifBlock.detach(detaching);

      if (detaching) {
        detach(ifBlockAnchor);
      }
    },
  );
}

var x = 7;

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
    );
  }
}
