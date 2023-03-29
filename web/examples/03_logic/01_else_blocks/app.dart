import 'dart:html';

import 'package:svelte/runtime.dart';

import 'user.dart';

Fragment createIfBLock(AppContext context) {
  late Element button;

  var mounted = false;

  late void Function() dispose;

  return Fragment(
    create: () {
      button = element('button');
      setText(button, 'Log out');
    },
    mount: (target, anchor) {
      insert(target, button, anchor);

      if (!mounted) {
        dispose = listen(button, 'click', listener(context.toggle));
        mounted = true;
      }
    },
    detach: (detaching) {
      if (detaching) {
        remove(button);
      }

      mounted = false;
      dispose();
    },
  );
}

Fragment createElseBlock(AppContext context) {
  late Element button;

  var mounted = false;

  late void Function() dispose;

  return Fragment(
    create: () {
      button = element('button');
      setText(button, 'Log in');
    },
    mount: (target, anchor) {
      insert(target, button, anchor);

      if (!mounted) {
        dispose = listen(button, 'click', listener(context.toggle));
        mounted = true;
      }
    },
    detach: (bool detaching) {
      if (detaching) {
        remove(button);
      }

      mounted = false;
      dispose();
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
    if (context.user.loggedIn) {
      return createIfBLock;
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

List<Object?> createInstance(
  Component self,
  Map<String, Object?> props,
  Invalidate invalidate,
) {
  var user = User(loggedIn: false);

  void toggle() {
    invalidate(0, user, user.loggedIn = !user.loggedIn);
  }

  return <Object?>[user, toggle];
}

class AppContext {
  AppContext(List<Object?> instance) : _instance = instance;

  final List<Object?> _instance;

  User get user {
    return unsafeCast<User>(_instance[0]);
  }

  void Function() get toggle {
    return unsafeCast<void Function()>(_instance[1]);
  }
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
      createInstance: createInstance,
      createFragment: createFragment,
      props: <String, int>{},
    );
  }
}
