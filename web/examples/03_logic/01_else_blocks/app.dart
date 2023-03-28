import 'dart:html';

import 'package:svelte/runtime.dart';

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
          ..mount(unsafeCast(ifBlockAnchor.parentNode), ifBlockAnchor);

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
  Props props,
  Invalidate invalidate,
) {
  var user = (loggedIn: false);

  void toggle() {
    invalidate(0, user = (loggedIn: !user.loggedIn));
  }

  return <Object?>[user, toggle];
}

class AppContext {
  AppContext(List<Object?> instance) : _instance = instance;

  final List<Object?> _instance;

  ({bool loggedIn}) get user {
    return unsafeCast(_instance[0]);
  }

  void Function() get toggle {
    return unsafeCast(_instance[1]);
  }
}

class App extends Component {
  App(Options options) {
    init(
      component: this,
      options: options,
      createInstance: createInstance,
      createFragment: createFragment,
      props: <String, int>{},
    );
  }
}
