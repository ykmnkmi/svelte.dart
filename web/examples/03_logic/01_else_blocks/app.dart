import 'dart:html';

import 'package:svelte/runtime.dart';

class IfBlock extends Fragment {
  IfBlock(this.instance);

  final AppInstance instance;

  late Element button;

  bool mounted = false;

  late void Function() dispose;

  @override
  void create() {
    button = element('button');
    setText(button, 'Log out');
  }

  @override
  void mount(Element target, Node? anchor) {
    insert(target, button, anchor);

    if (!mounted) {
      dispose = listen(button, 'click', listener(instance.toggle));
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

class ElseBlock extends Fragment {
  ElseBlock(this.instance);

  final AppInstance instance;

  late Element button;

  bool mounted = false;

  late void Function() dispose;

  @override
  void create() {
    button = element('button');
    setText(button, 'Log in');
  }

  @override
  void mount(Element target, Node? anchor) {
    insert(target, button, anchor);

    if (!mounted) {
      dispose = listen(button, 'click', listener(instance.toggle));
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
  return AppFragment(AppInstance(instance));
}

class AppFragment extends Fragment {
  AppFragment(this.instance);

  final AppInstance instance;

  late Node ifBlockAnchor;

  late Fragment Function(AppInstance instance) currentBlockFactory =
      selectCurrentBlock(instance, <int>[-1]);

  late Fragment ifBlock = currentBlockFactory(instance);

  Fragment Function(AppInstance instance) selectCurrentBlock(
      AppInstance instance, List<int> dirty) {
    if (instance.user['loggedIn']!) {
      return IfBlock.new;
    }

    return ElseBlock.new;
  }

  @override
  void create() {
    ifBlock.create();
    ifBlockAnchor = empty();
  }

  @override
  void mount(Element target, Node? anchor) {
    ifBlock.mount(target, anchor);
    insert(target, ifBlockAnchor, anchor);
  }

  @override
  void update(List<int> dirty) {
    if (currentBlockFactory ==
        (currentBlockFactory = selectCurrentBlock(instance, dirty))) {
      ifBlock.update(dirty);
    } else {
      ifBlock.detach(true);
      ifBlock = currentBlockFactory(instance);
      ifBlock.create();
      ifBlock.mount(unsafeCast(ifBlockAnchor.parentNode), ifBlockAnchor);
    }
  }

  @override
  void detach(bool detaching) {
    ifBlock.detach(detaching);

    if (detaching) {
      remove(ifBlockAnchor);
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
    invalidate(0, user = {'loggedIn': !user['loggedIn']!});
  }

  return <Object?>[user, toggle];
}

class AppInstance {
  AppInstance(List<Object?> instance) : _instance = instance;

  final List<Object?> _instance;

  Map<String, bool> get user {
    return unsafeCast(_instance[0]);
  }

  void Function() get toggle {
    return unsafeCast(_instance[1]);
  }
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
