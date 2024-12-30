import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart' show Element, Node;

import 'user.dart';

extension on List<Object?> {
  User get _user {
    return this[0] as User;
  }

  void Function() get _toggle {
    return this[1] as void Function();
  }
}

final class ElseBlockFragment extends Fragment {
  ElseBlockFragment(List<Object?> instance);

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

final class IfBlockFragment extends Fragment {
  IfBlockFragment(List<Object?> instance);

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

final class AppFragment extends Fragment {
  AppFragment(List<Object?> instance) {
    currentBlockType = selectBlockType(instance);
    ifBlock = currentBlockType(instance);
  }

  late Node ifBlockAnchor;

  late FragmentFactory currentBlockType;
  Fragment? ifBlock;

  FragmentFactory selectBlockType(List<Object?> instance) {
    if (instance._user.loggedIn) {
      return IfBlockFragment.new;
    }

    return ElseBlockFragment.new;
  }

  @override
  void create(List<Object?> instance) {
    ifBlock?.create(instance);
    ifBlockAnchor = empty();
  }

  @override
  void mount(List<Object?> instance, Element target, Node? anchor) {
    ifBlock?.mount(instance, target, anchor);
    insert(target, ifBlockAnchor, anchor);
  }

  @override
  void update(List<Object?> instance, int dirty) {
    if (currentBlockType == (currentBlockType = selectBlockType(instance)) &&
        ifBlock != null) {
      ifBlock!.update(instance, dirty);
    } else {
      ifBlock!.detach(true);
      ifBlock = currentBlockType(instance);

      if (ifBlock != null) {
        ifBlock!
          ..create(instance)
          ..mount(instance, ifBlockAnchor.parentNode as Element, ifBlockAnchor);
      }
    }
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(ifBlockAnchor);
    }

    ifBlock?.detach(detaching);
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
