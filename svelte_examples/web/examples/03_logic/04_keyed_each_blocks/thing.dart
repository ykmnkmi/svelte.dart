import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart' show Element, Node, Text;

extension on List<Object?> {
  String get _current {
    return this[0] as String;
  }

  String get _initial {
    return this[1] as String;
  }
}

final class ThingFragment extends Fragment {
  ThingFragment(List<Object?> instance);

  late Element p;
  late Element span0;
  late Text t0;
  late Text t1;
  late Element span1;
  late Text t2;

  @override
  void create(List<Object?> instance) {
    p = element('p');
    span0 = element('span');
    t0 = text('initial');
    t1 = space();
    span1 = element('span');
    t2 = text('current');
    setStyle(span0, 'background-color', instance._initial);
    setAttribute(span0, 'class', 'svelte-dgndg6');
    setStyle(span1, 'background-color', instance._current);
    setAttribute(span1, 'class', 'svelte-dgndg6');
  }

  @override
  void mount(List<Object?> context, Element target, Node? anchor) {
    insert(target, p, anchor);
    append(p, span0);
    append(span0, t0);
    append(p, t1);
    append(p, span1);
    append(span1, t2);
  }

  @override
  void update(List<Object?> context, int dirty) {
    if (dirty & 1 != 0) {
      setStyle(span1, 'background-color', context._current);
    }
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(p);
    }
  }
}

List<Object?> createInstance(
  Component self,
  Map<String, Object?> inputs,
  Invalidate invalidate,
) {
  String current = inputs['current'] as String;
  String initial = current;

  setComponentSetter(self, (Map<String, Object?> inputs) {
    if (inputs.containsKey('current')) {
      invalidate(0, current = inputs['current'] as String);
    }
  });

  return <Object?>[current, initial];
}

final class Thing extends Component {
  Thing({
    super.target,
    super.anchor,
    super.inputs,
    super.hydrate,
    super.intro,
  }) : super(
            createInstance: createInstance,
            createFragment: ThingFragment.new,
            properties: const <String, int>{'current': 0});
}
