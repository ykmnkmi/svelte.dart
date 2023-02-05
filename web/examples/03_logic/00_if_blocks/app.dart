import 'dart:html';

import 'package:svelte/runtime.dart';

Fragment createIfBlock0(List<Object?> instance) {
  return IfBlock0(instance);
}

class IfBlock0 extends Fragment {
  IfBlock0(this.instance);

  final List<Object?> instance;

  late Element button;

  bool mounted = false;

  late void Function() dispose;

  void Function() _toggle(List<Object?> instance) {
    return unsafeCast(instance[1]);
  }

  @override
  void create() {
    button = element('button');
    setText(button, 'Log out');
  }

  @override
  void mount(Element target, Node? anchor) {
    insert(target, button, anchor);

    if (!mounted) {
      dispose = listen(button, 'click', listener(_toggle(instance)));
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

Fragment createIfBlock1(List<Object?> instance) {
  return IfBlock1(instance);
}

class IfBlock1 extends Fragment {
  IfBlock1(this.instance);

  final List<Object?> instance;

  late Element button;

  bool mounted = false;

  late void Function() dispose;

  void Function() _toggle(List<Object?> instance) {
    return unsafeCast(instance[1]);
  }

  @override
  void create() {
    button = element('button');
    setText(button, 'Log in');
  }

  @override
  void mount(Element target, Node? anchor) {
    insert(target, button, anchor);

    if (!mounted) {
      dispose = listen(button, 'click', listener(_toggle(instance)));
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

Fragment createFragment(List<Object?> instance) {
  return AppFragment(instance);
}

class AppFragment extends Fragment {
  AppFragment(this.instance) {
    if (_user(instance)['loggedIn']!) {
      ifBlock0 = createIfBlock0(instance);
    }

    if (!_user(instance)['loggedIn']!) {
      ifBlock1 = createIfBlock1(instance);
    }
  }

  final List<Object?> instance;

  late Text t;

  late Node ifBlock1Anchor;

  Fragment? ifBlock0;

  Fragment? ifBlock1;

  Map<String, bool> _user(List<Object?> instance) {
    return unsafeCast(instance[0]);
  }

  @override
  void create() {
    ifBlock0?.create();
    t = space();
    ifBlock1?.create();
    ifBlock1Anchor = empty();
  }

  @override
  void mount(Element target, Node? anchor) {
    ifBlock0?.mount(target, anchor);
    insert(target, t, anchor);
    ifBlock1?.mount(target, anchor);
    insert(target, ifBlock1Anchor, anchor);
  }

  @override
  void update(List<Object?> instance, List<int> dirty) {
    if (_user(instance)['loggedIn']!) {
      if (ifBlock0 != null) {
        ifBlock0!.update(instance, dirty);
      } else {
        ifBlock0 = createIfBlock0(instance);
        ifBlock0!.create();
        ifBlock0!.mount(unsafeCast(t.parentNode), t);
      }
    } else if (ifBlock0 != null) {
      ifBlock0!.detach(true);
      ifBlock0 = null;
    }

    if (!_user(instance)['loggedIn']!) {
      if (ifBlock1 != null) {
        ifBlock1!.update(instance, dirty);
      } else {
        ifBlock1 = createIfBlock1(instance);
        ifBlock1!.create();
        ifBlock1!.mount(unsafeCast(ifBlock1Anchor.parentNode), ifBlock1Anchor);
      }
    } else if (ifBlock1 != null) {
      ifBlock1!.detach(true);
      ifBlock1 = null;
    }
  }

  @override
  void detach(bool detaching) {
    ifBlock0?.detach(detaching);

    if (detaching) {
      remove(t);
    }

    ifBlock1?.detach(detaching);

    if (detaching) {
      remove(ifBlock1Anchor);
    }
  }
}

List<Object?> createInstance(
  App self,
  Props props,
  Invalidate invalidate,
) {
  var user = {'loggedIn': false};

  void toggle() {
    invalidate(0, user, user = {'loggedIn': !user['loggedIn']!});
  }

  return <Object?>[user, toggle];
}

class App extends Component {
  App(Options options) {
    init<App>(
      component: this,
      options: options,
      createInstance: createInstance,
      createFragment: createFragment,
      props: <String, int>{},
    );
  }
}
