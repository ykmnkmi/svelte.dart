import 'dart:html';

import 'package:svelte_runtime/svelte_runtime.dart';

import 'user.dart';

Fragment createIfBlock(List<Object?> instance) {
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

Fragment createElseBlock(List<Object?> instance) {
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
  late Node ifBlockAnchor;

  Fragment Function(List<Object?>) selectCurrentBlock(
    List<Object?> context,
    List<int> dirty,
  ) {
    if (context._user.loggedIn) {
      return createIfBlock;
    }

    return createElseBlock;
  }

  var currentBlockFactory = selectCurrentBlock(instance, const <int>[-1]);
  var ifBlock = currentBlockFactory(instance);

  return Fragment(
    create: () {
      ifBlock.create();
      ifBlockAnchor = empty();
    },
    mount: (target, anchor) {
      ifBlock.mount(target, anchor);
      insert(target, ifBlockAnchor, anchor);
    },
    update: (context, dirty) {
      var newBlockFactory = selectCurrentBlock(context, dirty);

      if (currentBlockFactory == newBlockFactory) {
        ifBlock.update(context, dirty);
      } else {
        ifBlock.detach(true);

        ifBlock = newBlockFactory(context)
          ..create()
          ..mount(ifBlockAnchor.parent as Element, ifBlockAnchor);

        currentBlockFactory = newBlockFactory;
      }
    },
    detach: (detaching) {
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

extension on List<Object?> {
  User get _user {
    return this[0] as User;
  }

  void Function() get _toggle {
    return this[1] as void Function();
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
