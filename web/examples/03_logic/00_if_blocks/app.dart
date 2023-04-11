import 'package:svelte/runtime.dart';
import 'package:web/web.dart';

import 'user.dart';

Fragment createIfBlock0(List<Object?> instance) {
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
        dispose = listen(button, 'click', listener(instance._toggle));
        mounted = true;
      }
    },
    detach: (detaching) {
      if (detaching) {
        detach(button);
      }

      mounted = false;
      dispose();
    },
  );
}

Fragment createIfBlock1(List<Object?> instance) {
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
        dispose = listen(button, 'click', listener(instance._toggle));
        mounted = true;
      }
    },
    detach: (detaching) {
      if (detaching) {
        detach(button);
      }

      mounted = false;
      dispose();
    },
  );
}

Fragment createFragment(List<Object?> instance) {
  late Text t;
  late Node ifBlock1Anchor;

  Fragment? ifBlock0;
  Fragment? ifBlock1;

  if (instance._user.loggedIn) {
    ifBlock0 = createIfBlock0(instance);
  }

  if (!instance._user.loggedIn) {
    ifBlock1 = createIfBlock1(instance);
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
    update: (context, dirty) {
      if (context._user.loggedIn) {
        if (ifBlock0 != null) {
          ifBlock0!.update(context, dirty);
        } else {
          ifBlock0 = createIfBlock0(context)
            ..create()
            ..mount(unsafeCast<Element>(t.parentElement), t);
        }
      } else if (ifBlock0 != null) {
        ifBlock0!.detach(true);
        ifBlock0 = null;
      }

      if (!context._user.loggedIn) {
        if (ifBlock1 != null) {
          ifBlock1!.update(context, dirty);
        } else {
          ifBlock1 = createIfBlock1(context)
            ..create()
            ..mount(unsafeCast<Element>(ifBlock1Anchor.parentElement),
                ifBlock1Anchor);
        }
      } else if (ifBlock1 != null) {
        ifBlock1!.detach(true);
        ifBlock1 = null;
      }
    },
    detach: (detaching) {
      ifBlock0?.detach(detaching);

      if (detaching) {
        detach(t);
      }

      ifBlock1?.detach(detaching);

      if (detaching) {
        detach(ifBlock1Anchor);
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

extension on List<Object?> {
  User get _user {
    return unsafeCast<User>(this[0]);
  }

  void Function() get _toggle {
    return unsafeCast<void Function()>(this[1]);
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
      options: (
        target: target,
        anchor: anchor,
        props: props,
        hydrate: hydrate,
        intro: intro,
      ),
      createInstance: createInstance,
      createFragment: createFragment,
    );
  }
}
