import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart' show Element, Node;

import 'info.dart';

extension on List<Object?> {
  Map<String, Object?> get _pkg {
    return this[0] as Map<String, Object?>;
  }
}

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
    mount: (Element target, Node? anchor) {
      mountComponent(info, target, anchor);
      current = true;
    },
    update: (List<Object?> instance, int dirty) {
      Map<String, Object?> infoChanges;

      if (dirty & 1 != 0) {
        var list = <Map<String, Object?>>[getSpreadProps(instance._pkg)];
        infoChanges = getSpreadUpdate(infoSpreadLevels, list);
      } else {
        infoChanges = <String, Object?>{};
      }

      info.set(infoChanges);
    },
    intro: (bool local) {
      if (current) {
        return;
      }

      transitionInComponent(info, local);
      current = true;
    },
    outro: (bool local) {
      transitionOutComponent(info, local);
      current = false;
    },
    detach: (bool detaching) {
      destroyComponent(info, detaching);
    },
  );
}

List<Object?> createInstance(
  Component self,
  Map<String, Object?> props,
  Invalidate invalidate,
) {
  var pkg = <String, Object>{
    'name': 'svelte',
    'version': 3,
    'speed': 'blazing',
    'website': 'https://svelte.dev'
  };

  return <Object?>[pkg];
}

final class App extends Component {
  App({
    super.target,
    super.anchor,
    super.props,
    super.hydrate,
    super.intro,
  }) : super(createInstance: createInstance, createFragment: createFragment);
}
