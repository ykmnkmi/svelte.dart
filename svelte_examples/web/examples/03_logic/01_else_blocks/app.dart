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

Fragment createIfBlock(List<Object?> instance) {
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

Fragment createElseBlock(List<Object?> instance) {
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
  late Node ifBlockAnchor;

  FragmentFactory selectCurrentBlock(
    List<Object?> context,
    int dirty,
  ) {
    if (context._user.loggedIn) {
      return createIfBlock;
    }

    return createElseBlock;
  }

  var currentBlockFactory = selectCurrentBlock(instance, -1);
  var ifBlock = currentBlockFactory(instance);

  return Fragment(
    create: () {
      ifBlock.create();
      ifBlockAnchor = empty();
    },
    mount: (Element target, Node? anchor) {
      ifBlock.mount(target, anchor);
      insert(target, ifBlockAnchor, anchor);
    },
    update: (List<Object?> instance, int dirty) {
      var newBlockFactory = selectCurrentBlock(instance, dirty);

      if (currentBlockFactory == newBlockFactory) {
        ifBlock.update(instance, dirty);
      } else {
        ifBlock.detach(true);

        ifBlock = newBlockFactory(instance)
          ..create()
          ..mount(ifBlockAnchor.parentNode as Element, ifBlockAnchor);

        currentBlockFactory = newBlockFactory;
      }
    },
    detach: (bool detaching) {
      ifBlock.detach(detaching);

      if (detaching) {
        detach(ifBlockAnchor);
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
