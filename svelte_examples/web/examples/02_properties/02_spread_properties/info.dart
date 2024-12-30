import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart' show Element, Node, Text;

extension on List<Object?> {
  Object? get _name {
    return this[0];
  }

  Object? get _version {
    return this[1];
  }

  Object? get _speed {
    return this[2];
  }

  Object? get _website {
    return this[3];
  }
}

final class InfoFragment extends Fragment {
  InfoFragment(List<Object?> instance);

  late Element p0;
  late Text t0;
  late Element code0;
  late Text t1;
  late Text t2;
  late Text t3;
  late Text t4;
  late Text t5;
  late Text t6;
  late Element a0;
  late Text t7;
  late Text t8;
  late Element a1;
  late Text t9;
  late Text t10;

  @override
  void create(List<Object?> instance) {
    p0 = element('p');
    t0 = text('The ');
    code0 = element('code');
    t1 = text('${instance._name}');
    t2 = text(' package is ');
    t3 = text('${instance._speed}');
    t4 = text(' fast.\n\tDownload version ');
    t5 = text('${instance._version}');
    t6 = text(' from ');
    a0 = element('a');
    t7 = text('npm');
    t8 = text('\n\tand ');
    a1 = element('a');
    t9 = text('learn more here');
    t10 = text('.');
    setAttribute(a0, 'href', 'https://www.npmjs.com/package/${instance._name}');
    setAttribute(a1, 'href', '${instance._website}');
  }

  @override
  void mount(List<Object?> instance, Element target, Node? anchor) {
    insert(target, p0, anchor);
    append(p0, t0);
    append(p0, code0);
    append(code0, t1);
    append(p0, t2);
    append(p0, t3);
    append(p0, t4);
    append(p0, t5);
    append(p0, t6);
    append(p0, a0);
    append(a0, t7);
    append(p0, t8);
    append(p0, a1);
    append(a1, t9);
    append(p0, t10);
  }

  @override
  void update(List<Object?> instance, int dirty) {
    if (dirty & 1 != 0) {
      setData(t1, '${instance._name}');
    }

    if (dirty & 4 != 0) {
      setData(t3, '${instance._speed}');
    }

    if (dirty & 2 != 0) {
      setData(t5, '${instance._version}');
    }

    if (dirty & 1 != 0) {
      setAttribute(
          a0, 'href', 'https://www.npmjs.com/package/${instance._name}');
    }

    if (dirty & 8 != 0) {
      setAttribute(a1, 'href', '${instance._website}');
    }
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(p0);
    }
  }
}

List<Object?> createInstance(
  Component self,
  Map<String, Object?> props,
  Invalidate invalidate,
) {
  var name = props['name'];
  var version = props['version'];
  var speed = props['speed'];
  var website = props['website'];

  setComponentSetter(self, (Map<String, Object?> props) {
    if (props.containsKey('name')) {
      invalidate(0, name = props['name']);
    }

    if (props.containsKey('version')) {
      invalidate(1, version = props['version']);
    }

    if (props.containsKey('speed')) {
      invalidate(2, speed = props['speed']);
    }

    if (props.containsKey('website')) {
      invalidate(3, website = props['website']);
    }
  });

  return <Object?>[name, version, speed, website];
}

final class Info extends Component {
  Info({
    super.target,
    super.anchor,
    super.inputs,
    super.hydrate,
    super.intro,
  }) : super(
            createInstance: createInstance,
            createFragment: InfoFragment.new,
            properties: const <String, int>{
              'name': 0,
              'version': 1,
              'speed': 2,
              'website': 3
            });
}
