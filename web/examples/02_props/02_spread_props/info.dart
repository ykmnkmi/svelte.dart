import 'dart:html';

import 'package:svelte/runtime.dart';

Fragment createFragment(List<Object?> instance) {
  var context = InfoContext(instance);

  late Element p0;
  late Text t0;
  late Element code0;
  late Text t1, t2, t3, t4, t5, t6;
  late String a0href;
  late Element a0;
  late Text t7, t8;
  late Element a1;
  late Text t9;

  return Fragment(
    create: () {
      p0 = element('p');
      t0 = text('The ');
      code0 = element('code');
      t1 = text('${context.name}');
      t2 = text(' package is ');
      t3 = text('${context.speed}');
      t4 = text(' fast.\n\tDownload version ');
      t5 = text('${context.version}');
      t6 = text(' from ');
      a0 = element('a');
      t7 = text('pub');
      t8 = text('\n\tand ');
      a1 = element('a');
      t9 = text('learn more here');
      setAttribute(
          a0, 'href', a0href = 'https://pub.dev/package/${context.name}');
      setAttribute(a1, 'href', '${context.website}');
    },
    mount: (target, anchor) {
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
    },
    update: (dirty) {
      if (dirty[0] & 1 != 0) {
        setData(t1, '${context.name}');
      }

      if (dirty[0] & 4 != 0) {
        setData(t3, '${context.speed}');
      }

      if (dirty[0] & 2 != 0) {
        setData(t5, '${context.version}');
      }

      if (dirty[0] & 1 != 0 &&
          a0href !=
              (a0href = 'https://www.npmjs.com/package/${context.name}')) {
        setAttribute(a0, 'href', a0href);
      }

      if (dirty[0] & 8 != 0) {
        setAttribute(a1, 'href', '${context.website}');
      }
    },
    detach: (detaching) {
      if (detaching) {
        remove(p0);
      }
    },
  );
}

List<Object?> createInstance(
  Component self,
  Props props,
  Invalidate invalidate,
) {
  var name = props['name'];
  var version = props['version'];
  var speed = props['speed'];
  var website = props['website'];

  setComponentSet(self, (props) {
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

class InfoContext {
  const InfoContext(List<Object?> instance) : _instance = instance;

  final List<Object?> _instance;

  Object? get name {
    return _instance[0];
  }

  Object? get version {
    return _instance[1];
  }

  Object? get speed {
    return _instance[2];
  }

  Object? get website {
    return _instance[3];
  }
}

class Info extends Component {
  Info(Options options) {
    init(
      component: this,
      options: options,
      createInstance: createInstance,
      createFragment: createFragment,
      props: <String, int>{
        'answer': 0,
        'version': 1,
        'speed': 2,
        'website': 3,
      },
    );
  }
}
