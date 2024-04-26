import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart' show Element, Node, Text;

import 'user.dart';

extension on List<Object?> {
  User get _user {
    return this[0] as User;
  }

  void Function() get _toggle {
    return this[1] as void Function();
  }
}

Fragment createIfBlock0(List<Object?> instance) {
  late Element button;

  var mounted = false;

  late void Function() dispose;

  return Fragment(
    create: () {
      button = element('button');
      setText(button, 'Log out');
    },
    mount: (Element target, Node? anchor) {
      insert(target, button, anchor);

      if (!mounted) {
        dispose = listen(button, 'click', listener(instance._toggle));
        mounted = true;
      }
    },
    detach: (bool detaching) {
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
    mount: (Element target, Node? anchor) {
      insert(target, button, anchor);

      if (!mounted) {
        dispose = listen(button, 'click', listener(instance._toggle));
        mounted = true;
      }
    },
    detach: (bool detaching) {
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
    mount: (Element target, Node? anchor) {
      ifBlock0?.mount(target, anchor);
      insert(target, t, anchor);
      ifBlock1?.mount(target, anchor);
      insert(target, ifBlock1Anchor, anchor);
    },
    update: (List<Object?> instance, int dirty) {
      if (instance._user.loggedIn) {
        if (ifBlock0 != null) {
          ifBlock0!.update(instance, dirty);
        } else {
          ifBlock0 = createIfBlock0(instance)
            ..create()
            ..mount(t.parentNode as Element, t);
        }
      } else if (ifBlock0 != null) {
        ifBlock0!.detach(true);
        ifBlock0 = null;
      }

      if (!instance._user.loggedIn) {
        if (ifBlock1 != null) {
          ifBlock1!.update(instance, dirty);
        } else {
          ifBlock1 = createIfBlock1(instance)
            ..create()
            ..mount(ifBlock1Anchor.parentNode as Element, ifBlock1Anchor);
        }
      } else if (ifBlock1 != null) {
        ifBlock1!.detach(true);
        ifBlock1 = null;
      }
    },
    detach: (bool detaching) {
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

final class App extends Component {
  App({
    super.target,
    super.anchor,
    super.properties,
    super.hydrate,
    super.intro,
  }) : super(createInstance: createInstance, createFragment: createFragment);
}
