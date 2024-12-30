import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart' show Element, Node, Text, window;

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
  late Text t0;
  late Text t1;
  late Text t2;
  late Text t3;
  late String t3value;

  bool mounted = false;

  late void Function() dispose;

  @override
  void create(List<Object?> instance) {
    button = element('button');
    t0 = text('Clicked ');
    t1 = text('${instance._count}');
    t2 = space();
    t3 = text(t3value = instance._count == 1 ? 'time' : 'times');
  }

  @override
  void mount(List<Object?> instance, Element target, Node? anchor) {
    insert(target, button, anchor);
    append(button, t0);
    append(button, t1);
    append(button, t2);
    append(button, t3);

    if (!mounted) {
      dispose = listen(button, 'click', listener(instance._handleClick));
      mounted = true;
    }
  }

  @override
  void update(List<Object?> context, int dirty) {
    if (dirty & 1 != 0) {
      setData(t1, '${context._count}');

      if (t3value != (t3value = context._count == 1 ? 'time' : 'times')) {
        setData(t3, t3value);
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

  setComponentUpdate(self, () {
    return (State state) {
      if (state.dirty & 1 != 0) {
        $:
        if (count >= 10) {
          window.alert('count is dangerously high!');
          invalidate(0, count = 9);
        }
      }
    };
  });

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
