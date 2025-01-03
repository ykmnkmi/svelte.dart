import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart' show Element, Node, Text;

extension on List<Object?> {
  int get _count {
    return this[0] as int;
  }

  void Function() get _handleClick {
    return this[1] as void Function();
  }
}

final class AppFragment extends Fragment {
  AppFragment(List<Object?> instance);

  late Element button;
  late Text t1;
  late Text t2;
  late Text t3;
  late Text t4;
  late String t4value;

  bool mounted = false;

  late void Function() dispose;

  @override
  void create(List<Object?> instance) {
    button = element('button');
    t1 = text('Clicked ');
    t2 = text('${instance._count}');
    t3 = space();
    t4 = text(t4value = instance._count == 1 ? 'time' : 'times');
  }

  @override
  void mount(List<Object?> instance, Element target, Node? anchor) {
    insert(target, button, anchor);
    append(button, t1);
    append(button, t2);
    append(button, t3);
    append(button, t4);

    if (!mounted) {
      dispose = listen(button, 'click', listener(instance._handleClick));
      mounted = true;
    }
  }

  @override
  void update(List<Object?> instance, int dirty) {
    if (dirty & 1 != 0) {
      setData(t2, '${instance._count}');

      if (t4value != (t4value = instance._count == 1 ? 'time' : 'times')) {
        setData(t4, t4value);
      }
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

List<Object?> createInstance(
  Component self,
  Map<String, Object?> props,
  Invalidate invalidate,
) {
  var count = 0;

  void handleClick() {
    invalidate(0, count += 1);
  }

  return <Object?>[count, handleClick];
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
