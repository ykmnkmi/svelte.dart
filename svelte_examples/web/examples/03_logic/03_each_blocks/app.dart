import 'dart:math' show min;

import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart' show Element, Node, Text;

extension on List<Object?> {
  List<({String id, String name})> get cats {
    return this[0] as List<({String id, String name})>;
  }
}

List<Object?> getEachContext(
  List<Object?> context,
  List<({String id, String name})> list,
  int index,
) {
  return List<Object?>.of(context)
    ..length = 5
    ..[1] = list[index].id
    ..[2] = list[index].name
    ..[4] = index;
}

Fragment createEachBlock(List<Object?> instance) {
  return const Fragment();
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
    mount: (Element target, Node? anchor) {
      insert(target, h1, anchor);
      insert(target, t1, anchor);
      insert(target, ul, anchor);

      for (var eachBlock in eachBlocks) {
        eachBlock.mount(ul, null);
      }
    },
    update: (List<Object?> instance, int dirty) {
      if (dirty & 1 != 0) {
        eachValue = instance.cats;

        var length = min(eachBlocks.length, eachValue.length);
        var index = 0;

        for (; index < length; index += 1) {
          var eachContext = getEachContext(instance, eachValue, index);
          eachBlocks[index].update(eachContext, dirty);
        }

        if (index < eachValue.length) {
          for (; index < eachValue.length; index += 1) {
            var eachContext = getEachContext(instance, eachValue, index);
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
    detach: (bool detaching) {
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
  var cats = [
    (id: 'J---aiyznGQ', name: 'Keyboard Cat'),
    (id: 'z_AbfPXTKms', name: 'Maru'),
    (id: 'OUtn3pvWmpg', name: 'Henri The Existential Cat'),
  ];

  return <Object?>[cats];
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
