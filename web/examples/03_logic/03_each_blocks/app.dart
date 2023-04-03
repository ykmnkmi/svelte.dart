import 'dart:html';
import 'dart:math' show min;

import 'package:svelte/runtime.dart';

import 'cat.dart';

List<Object?> getEachContext(
  List<Object?> context,
  List<Cat> list,
  int index,
) {
  var childContext = context.toList();
  childContext.length = 5;
  childContext[1] = list[index].id;
  childContext[2] = list[index].name;
  childContext[4] = index;
  return childContext;
}

Fragment createEachBlock(List<Object?> instance) {
  print(instance.getRange(1, 5));

  return Fragment(
    create: () {},
    mount: (target, anchor) {},
    detach: (detaching) {},
  );
}

Fragment createFragment(List<Object?> instance) {
  late Element h1;
  late Text t1;
  late Element ul;

  var eachValue = instance.cats;

  Fragment generateEach(int index) {
    var eachContext = getEachContext(instance, eachValue, index);
    return createEachBlock(eachContext);
  }

  var eachBlocks = List<Fragment>.generate(eachValue.length, generateEach);

  return Fragment(
    create: () {
      h1 = element('h1');
      setText(h1, 'The Famous Cats of YouTube');
      t1 = space();
      ul = element('ul');

      for (var eachBlock in eachBlocks) {
        eachBlock.create();
      }
    },
    mount: (target, anchor) {
      insert(target, h1, anchor);
      insert(target, t1, anchor);
      insert(target, ul, anchor);

      for (var eachBlock in eachBlocks) {
        eachBlock.mount(ul, null);
      }
    },
    update: (context, dirty) {
      if (dirty[0] & 1 != 0) {
        eachValue = context.cats;

        var length = min(eachBlocks.length, eachValue.length);
        var index = 0;

        for (; index < length; index += 1) {
          var eachContext = getEachContext(context, eachValue, index);
          eachBlocks[index].update(eachContext, dirty);
        }

        if (index < eachValue.length) {
          for (; index < eachValue.length; index += 1) {
            var eachContext = getEachContext(context, eachValue, index);
            var newBlocks = createEachBlock(eachContext)
              ..create()
              ..mount(ul, null);

            eachBlocks.add(newBlocks);
          }
        } else if (index < eachBlocks.length) {
          for (; index < eachBlocks.length; index += 1) {
            eachBlocks[index].detach(true);
          }
        }
      }
    },
    detach: (detaching) {
      if (detaching) {
        detach(h1);
        detach(t1);
        detach(ul);
      }

      Fragment.detachAll(eachBlocks, detaching);
    },
  );
}

List<Object?> createInstance(
  Component self,
  Map<String, Object?> props,
  Invalidate invalidate,
) {
  var cats = <Cat>[
    Cat('J---aiyznGQ', 'Keyboard Cat'),
    Cat('z_AbfPXTKms', 'Maru'),
    Cat('OUtn3pvWmpg', 'Henri The Existential Cat'),
  ];

  return <Object?>[cats];
}

extension on List<Object?> {
  List<Cat> get cats {
    return unsafeCast<List<Cat>>(this[0]);
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
      options: Options(
        target: target,
        anchor: anchor,
        props: props,
        hydrate: hydrate,
        intro: intro,
      ),
      createInstance: createInstance,
      createFragment: createFragment,
      props: <String, int>{},
    );
  }
}
