import 'dart:html';

import 'package:svelte/runtime.dart';

Fragment createFragment(List<Object?> instance) {
  return AppFragment(instance);
}

class AppFragment extends Fragment {
  AppFragment(this.instance);

  final List<Object?> instance;

  late ButtonElement button;

  late Text t0, t1, t2;

  late ParagraphElement p0;

  late Text t3, t4, t5, t6;

  late ParagraphElement p1;

  late Text t7, t8, t9;

  bool mounted = false;

  late void Function() dispose;

  @override
  void create() {
    button = element<ButtonElement>('button');
    t0 = text('Count: ');
    t1 = text('${instance[0]}');
    t2 = space();
    p0 = element<ParagraphElement>('p');
    t3 = text('${instance[0]}');
    t4 = text(' * 2 = ');
    t5 = text('${instance[1]}');
    t6 = space();
    p1 = element<ParagraphElement>('p');
    t7 = text('${instance[1]}');
    t8 = text(' * 2 = ');
    t9 = text('${instance[2]}');
  }

  @override
  void mount(Element target, Node? anchor) {
    insert(target, button, anchor);
    append(button, t0);
    append(button, t1);
    insert(target, t2, anchor);
    insert(target, p0, anchor);
    append(p0, t3);
    append(p0, t4);
    append(p0, t5);
    insert(target, t6, anchor);
    insert(target, p1, anchor);
    append(p1, t7);
    append(p1, t8);
    append(p1, t9);

    if (!mounted) {
      var calback = instance[3] as void Function();
      dispose = listen(button, 'click', listener(calback));
      mounted = true;
    }
  }

  @override
  void update(List<Object?> instance, List<int> dirty) {
    if (dirty[0] & 1 != 0) {
      setData(t1, '${instance[0]}');
      setData(t3, '${instance[0]}');
    }

    if (dirty[0] & 2 != 0) {
      setData(t5, '${instance[1]}');
      setData(t7, '${instance[1]}');
    }

    if (dirty[0] & 4 != 0) {
      setData(t9, '${instance[2]}');
    }
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(button);
      remove(t2);
      remove(p0);
      remove(t6);
      remove(p1);
    }

    mounted = false;
    dispose();
  }
}

List<Object?> createInstance(
  App component,
  Map<String, Object?> props,
  Invalidate invalidate,
) {
  int count = 1;
  late int doubled;
  late int quadrupled;

  void handleClick() {
    invalidate(0, count += 1);
  }

  setComponentUpdate(component, (List<int> dirty) {
    return () {
      if (dirty[0] & 1 != 0) {
        invalidate(1, doubled = count * 2);
      }

      if (dirty[0] & 2 != 0) {
        invalidate(2, quadrupled = doubled * 2);
      }
    };
  });

  return <Object?>[count, null, null, handleClick];
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
