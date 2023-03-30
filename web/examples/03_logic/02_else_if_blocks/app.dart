import 'dart:html';

import 'package:svelte/runtime.dart';

Fragment createIfBlock1(AppContext context) {
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
        remove(p);
      }
    },
  );
}

Fragment createIfBlock2(AppContext context) {
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
        remove(p);
      }
    },
  );
}

Fragment createElseBlock(AppContext context) {
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
        remove(p);
      }
    },
  );
}

Fragment createFragment(List<Object?> instance) {
  var context = AppContext(instance);

  late Node ifBlockAnchor;

  Fragment Function(AppContext) selectCurrentBlock(
    AppContext context,
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

  var currentBlockFactory = selectCurrentBlock(context, <int>[-1]);
  var ifBlock = currentBlockFactory(context);

  return Fragment(
    create: () {
      ifBlock.create();
      ifBlockAnchor = empty();
    },
    mount: (target, anchor) {
      ifBlock.mount(target, anchor);
      insert(target, ifBlockAnchor, anchor);
    },
    update: (dirty) {
      var newBlockFactory = selectCurrentBlock(context, dirty);

      if (currentBlockFactory == newBlockFactory) {
        ifBlock.update(dirty);
      } else {
        ifBlock.detach(true);

        ifBlock = newBlockFactory(context)
          ..create()
          ..mount(unsafeCast<Element>(ifBlockAnchor.parent), ifBlockAnchor);

        currentBlockFactory = newBlockFactory;
      }
    },
    detach: (detaching) {
      ifBlock.detach(detaching);

      if (detaching) {
        remove(ifBlockAnchor);
      }
    },
  );
}

var x = 7;

class AppContext {
  const AppContext(this._instance);

  final List<Object?> _instance;
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
      options: Options(
        target: target,
        anchor: anchor,
        props: props,
        hydrate: hydrate,
        intro: intro,
      ),
      createFragment: createFragment,
      props: <String, int>{},
    );
  }
}
