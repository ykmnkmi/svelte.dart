import 'package:svelte/runtime.dart';

import 'info.dart';

Fragment createFragment(List<Object?> instance) {
  var context = AppContext(instance);

  Info info;

  var current = false;

  var infoSpreadLevels = <Map<String, Object?>>[context.pkg];
  var infoProps = <String, Object?>{};

  for (var i = 0; i < infoSpreadLevels.length; i += 1) {
    infoProps.addAll(infoSpreadLevels[i]);
  }

  info = Info(Options(props: infoProps));

  return Fragment(
    create: () {
      createComponent(info);
    },
    mount: (target, anchor) {
      mountComponent(info, target, anchor);
      current = true;
    },
    update: (dirty) {
      Map<String, Object?> infoChanges;

      if (dirty[0] & 1 != 0) {
        var list = <Map<String, Object?>>[getSpreadProps(context.pkg)];
        infoChanges = getSpreadUpdate(infoSpreadLevels, list);
      } else {
        infoChanges = <String, Object?>{};
      }

      info.set(infoChanges);
    },
    intro: (local) {
      if (current) {
        return;
      }

      transitionInComponent(info, local);
      current = true;
    },
    outro: (local) {
      transitionOutComponent(info, local);
      current = false;
    },
    detach: (detaching) {
      destroyComponent(info, detaching);
    },
  );
}

List<Object?> createInstance(
  Component self,
  Map<String, Object?> props,
  void Function(int i, Object? value) invalidate,
) {
  final pkg = {
    'name': 'svelte',
    'version': 3,
    'speed': 'blazing',
    'website': 'https://svelte.dev'
  };

  return <Object?>[pkg];
}

class AppContext {
  const AppContext(List<Object?> instance) : _instance = instance;

  final List<Object?> _instance;

  Map<String, Object?> get pkg {
    return unsafeCast(_instance[0]);
  }
}

class App extends Component {
  App(Options options) {
    init(
      component: this,
      options: options,
      createInstance: createInstance,
      createFragment: createFragment,
      props: <String, int>{},
    );
  }
}
