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

final class IfBlock0Fragment extends Fragment {
  IfBlock0Fragment(List<Object?> instance);

  late Element button;

  bool mounted = false;

  late void Function() dispose;

  @override
  void create(List<Object?> instance) {
    button = element('button');
    setText(button, 'Log out');
  }

  @override
  void mount(List<Object?> instance, Element target, Node? anchor) {
    insert(target, button, anchor);

    if (!mounted) {
      dispose = listen(button, 'click', listener(instance._toggle));
      mounted = true;
    }
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(button);
    }

    mounted = false;
    dispose();
  }
}

final class IfBlock1Fragment extends Fragment {
  IfBlock1Fragment(List<Object?> instance);

  late Element button;

  bool mounted = false;

  late void Function() dispose;

  @override
  void create(List<Object?> instance) {
    button = element('button');
    setText(button, 'Log in');
  }

  @override
  void mount(List<Object?> instance, Element target, Node? anchor) {
    insert(target, button, anchor);

    if (!mounted) {
      dispose = listen(button, 'click', listener(instance._toggle));
      mounted = true;
    }
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(button);
    }

    mounted = false;
    dispose();
  }
}

final class AppFragment extends Fragment {
  AppFragment(List<Object?> instance) {
    if (instance._user.loggedIn) {
      ifBlock0 = IfBlock0Fragment(instance);
    }

    if (!instance._user.loggedIn) {
      ifBlock1 = IfBlock1Fragment(instance);
    }
  }

  late Text t;
  late Node ifBlock1Anchor;

  Fragment? ifBlock0;
  Fragment? ifBlock1;

  @override
  void create(List<Object?> instance) {
    ifBlock0?.create(instance);
    t = space();
    ifBlock1?.create(instance);
    ifBlock1Anchor = empty();
  }

  @override
  void mount(List<Object?> instance, Element target, Node? anchor) {
    ifBlock0?.mount(instance, target, anchor);
    insert(target, t, anchor);
    ifBlock1?.mount(instance, target, anchor);
    insert(target, ifBlock1Anchor, anchor);
  }

  @override
  void update(List<Object?> instance, int dirty) {
    if (instance._user.loggedIn) {
      if (ifBlock0 != null) {
        ifBlock0!.update(instance, dirty);
      } else {
        ifBlock0 = IfBlock0Fragment(instance)
          ..create(instance)
          ..mount(instance, t.parentNode as Element, t);
      }
    } else if (ifBlock0 != null) {
      ifBlock0!.detach(true);
      ifBlock0 = null;
    }

    if (!instance._user.loggedIn) {
      if (ifBlock1 != null) {
        ifBlock1!.update(instance, dirty);
      } else {
        ifBlock1 = IfBlock1Fragment(instance)
          ..create(instance)
          ..mount(
              instance, ifBlock1Anchor.parentNode as Element, ifBlock1Anchor);
      }
    } else if (ifBlock1 != null) {
      ifBlock1!.detach(true);
      ifBlock1 = null;
    }
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(t);
      remove(ifBlock1Anchor);
    }

    ifBlock0?.detach(detaching);
    ifBlock1?.detach(detaching);
  }
}

List<Object?> createInstance(
  Component self,
  Map<String, Object?> inputs,
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
    super.inputs,
    super.hydrate,
    super.intro,
  }) : super(createInstance: createInstance, createFragment: AppFragment.new);
}
