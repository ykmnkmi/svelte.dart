import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart' show Element, Node;

import 'info.dart';

extension on List<Object?> {
  Map<String, Object?> get _pkg {
    return this[0] as Map<String, Object?>;
  }
}

final class AppFragment extends Fragment {
  AppFragment(List<Object?> instance) {
    infoSpreadLevels = <Map<String, Object?>>[instance._pkg];

    Map<String, Object?> infoProps = <String, Object?>{};

    for (int i = 0; i < infoSpreadLevels.length; i += 1) {
      infoProps.addAll(infoSpreadLevels[i]);
    }

    info = Info(inputs: infoProps);
  }

  late Info info;
  late List<Map<String, Object?>> infoSpreadLevels;

  bool current = false;

  @override
  void create(List<Object?> instance) {
    createComponent(info);
  }

  @override
  void mount(List<Object?> instance, Element target, Node? anchor) {
    mountComponent(info, target, anchor);
    current = true;
  }

  @override
  void update(List<Object?> instance, int dirty) {
    Map<String, Object?> infoChanges;

    if (dirty & 1 != 0) {
      List<Map<String, Object?>> list = <Map<String, Object?>>[
        getSpreadProps(instance._pkg)
      ];

      infoChanges = getSpreadUpdate(infoSpreadLevels, list);
    } else {
      infoChanges = <String, Object?>{};
    }

    info.set(infoChanges);
  }

  @override
  void intro(bool local) {
    if (current) {
      return;
    }

    transitionInComponent(info, local);
    current = true;
  }

  @override
  void outro(bool local) {
    transitionOutComponent(info, local);
    current = false;
  }

  @override
  void detach(bool detaching) {
    destroyComponent(info, detaching);
  }
}

List<Object?> createInstance(
  Component self,
  Map<String, Object?> props,
  Invalidate invalidate,
) {
  var pkg = <String, Object>{
    'name': 'svelte',
    'version': 5,
    'speed': 'blazing',
    'website': 'https://svelte.dev'
  };

  return <Object?>[pkg];
}

final class App extends Component {
  App({
    super.target,
    super.anchor,
    super.properties,
    super.hydrate,
    super.intro,
  }) : super(createInstance: createInstance, createFragment: AppFragment.new);
}
