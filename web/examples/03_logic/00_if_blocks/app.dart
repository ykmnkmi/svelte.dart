import 'dart:html';

import 'package:svelte/runtime.dart';

import 'user.dart';

Fragment createIfBlock0(AppContext context) {
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

Fragment createIfBlock1(AppContext context) {
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
    detach: (detaching) {
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

  late Text t;
  late Node ifBlock1Anchor;

  Fragment? ifBlock0;
  Fragment? ifBlock1;

  if (context.user.loggedIn) {
    ifBlock0 = createIfBlock0(context);
  }

  if (!context.user.loggedIn) {
    ifBlock1 = createIfBlock0(context);
  }

  return Fragment(
    create: () {
      ifBlock0?.create();
      t = space();
      ifBlock1?.create();
      ifBlock1Anchor = empty();
    },
    mount: (target, anchor) {
      ifBlock0?.mount(target, anchor);
      insert(target, t, anchor);
      ifBlock1?.mount(target, anchor);
      insert(target, ifBlock1Anchor, anchor);
    },
    update: (dirty) {
      if (context.user.loggedIn) {
        if (ifBlock0 != null) {
          ifBlock0!.update(dirty);
        } else {
          ifBlock0 = createIfBlock0(context)
            ..create()
            ..mount(unsafeCast<Element>(t.parent), t);
        }
      } else if (ifBlock0 != null) {
        ifBlock0!.detach(true);
        ifBlock0 = null;
      }

      if (!context.user.loggedIn) {
        if (ifBlock1 != null) {
          ifBlock1!.update(dirty);
        } else {
          ifBlock1 = createIfBlock1(context)
            ..create()
            ..mount(unsafeCast<Element>(ifBlock1Anchor.parent), ifBlock1Anchor);
        }
      } else if (ifBlock1 != null) {
        ifBlock1!.detach(true);
        ifBlock1 = null;
      }
    },
    detach: (detaching) {
      ifBlock0?.detach(detaching);

      if (detaching) {
        remove(t);
      }

      ifBlock1?.detach(detaching);

      if (detaching) {
        remove(ifBlock1Anchor);
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
