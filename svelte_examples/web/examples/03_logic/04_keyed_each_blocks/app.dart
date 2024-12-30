import 'dart:math' show min;

import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart' show Element, Node, Text;

extension on List<Object?> {
  List<({String color, int id})> get cats {
    return this[0] as List<({String color, int id})>;
  }
}

List<Object?> getEachContext(
  List<Object?> context,
  List<({String color, int id})> list,
  int index,
) {
  return List<Object?>.of(context)..[2] = list[index];
}

List<Object?> getEachContext1(
  List<Object?> context,
  List<({String color, int id})> list,
  int index,
) {
  return List<Object?>.of(context)..[2] = list[index];
}

final class EachBlock1Fragment extends Fragment {
  EachBlock1Fragment(List<Object?> instance) {
    t0Value = '${(instance[4] as int) + 1}';
    t2Value = instance[2] as String;
  }

  late Element li;
  late Element a;
  late String t0Value;
  late Text t0;
  late Text t1;
  late String t2Value;
  late Text t2;
  late Text t3;

  @override
  void create(List<Object?> instance) {
    li = element('li');
    a = element('a');
    t0 = text(t0Value);
    t1 = text(': ');
    t2 = text(t2Value);
    t3 = space();
    setAttribute(a, 'target', '_blank');
    setAttribute(a, 'rel', 'noreferrer');
    setAttribute(a, 'href', 'https://www.youtube.com/watch?v=${instance[1]}');
  }

  @override
  void mount(List<Object?> instance, Element target, Node? anchor) {
    insert(target, li, anchor);
    append(li, a);
    append(a, t0);
    append(a, t1);
    append(a, t2);
    append(li, t3);
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(li);
    }
  }
}

final class AppFragment extends Fragment {
  AppFragment(List<Object?> instance) {
    eachValue = instance.cats;
    eachBlocks = List<Fragment>.generate(
        eachValue.length, (i) => generateEach(instance, i));
  }

  late Element h1;
  late Text t1;
  late Element ul;

  late List<({String color, int id})> eachValue;
  late List<Fragment> eachBlocks;

  Fragment generateEach(List<Object?> instance, int index) {
    List<Object?> eachContext = getEachContext(instance, eachValue, index);
    return EachBlockFragment(eachContext);
  }

  @override
  void create(List<Object?> instance) {
    h1 = element('h1');
    setText(h1, 'The Famous Cats of YouTube');
    t1 = space();
    ul = element('ul');

    for (int i = 0; i < eachBlocks.length; i += 1) {
      List<Object?> eachContext = getEachContext(instance, eachValue, i);
      eachBlocks[i].create(eachContext);
    }
  }

  @override
  void mount(List<Object?> instance, Element target, Node? anchor) {
    insert(target, h1, anchor);
    insert(target, t1, anchor);
    insert(target, ul, anchor);

    for (int i = 0; i < eachBlocks.length; i += 1) {
      eachBlocks[i].mount(instance, ul, null);
    }
  }

  @override
  void update(List<Object?> instance, int dirty) {
    if (dirty & 1 != 0) {
      eachValue = instance.cats;

      int i = 0;
      int length = min(eachBlocks.length, eachValue.length);

      for (; i < length; i += 1) {
        List<Object?> eachContext = getEachContext(instance, eachValue, i);
        eachBlocks[i].update(eachContext, dirty);
      }

      if (i < eachValue.length) {
        for (; i < eachValue.length; i += 1) {
          List<Object?> eachContext = getEachContext(instance, eachValue, i);
          EachBlockFragment newBlocks = EachBlockFragment(eachContext)
            ..create(eachContext)
            ..mount(eachContext, ul, null);

          eachBlocks.add(newBlocks);
        }
      } else if (i < eachBlocks.length) {
        for (; i < eachBlocks.length; i += 1) {
          eachBlocks[i].detach(true);
        }
      }
    }
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(h1);
      remove(t1);
      remove(ul);
    }

    Fragment.detachAll(eachBlocks, detaching);
  }
}

List<Object?> createInstance(
  Component self,
  Map<String, Object?> inputs,
  Invalidate invalidate,
) {
  var things = [
    (id: 1, color: 'darkblue'),
    (id: 2, color: 'indigo'),
    (id: 3, color: 'deeppink'),
    (id: 4, color: 'salmon'),
    (id: 5, color: 'gold')
  ];

  void handleClick() {
    if (things.isNotEmpty) {
      invalidate(0, things = things.sublist(1));
    }
  }

  return <Object?>[things, handleClick];
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
