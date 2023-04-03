import 'dart:html';

import 'package:svelte/runtime.dart';

import 'info.dart';

Fragment createFragment(List<Object?> instance) {
  Info info;

  var current = false;

  var infoSpreadLevels = <Map<String, Object?>>[instance._pkg];
  var infoProps = <String, Object?>{};

  for (var i = 0; i < infoSpreadLevels.length; i += 1) {
    infoProps.addAll(infoSpreadLevels[i]);
  }

  info = Info(props: infoProps);

  return Fragment(
    create: () {
      createComponent(info);
    },
    mount: (target, anchor) {
      mountComponent(info, target, anchor);
      current = true;
    },
    update: (context, dirty) {
      Map<String, Object?> infoChanges;

      if (dirty[0] & 1 != 0) {
        var list = <Map<String, Object?>>[getSpreadProps(context._pkg)];
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
  var pkg = <String, Object>{
    'name': 'svelte',
    'version': 3,
    'speed': 'blazing',
    'website': 'https://svelte.dev'
  };

  return <Object?>[pkg];
}

extension on List<Object?> {
  Map<String, Object?> get _pkg {
    return unsafeCast<Map<String, Object?>>(this[0]);
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
