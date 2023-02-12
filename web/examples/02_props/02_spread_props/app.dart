import 'dart:html';

import 'package:svelte/runtime.dart';

import 'info.dart';

Fragment createFragment(List<Object?> instance) {
  return AppFragment(AppInstance(instance));
}

class AppFragment extends Fragment {
  AppFragment(this.instance) {
    infoSpreadLevels = <Map<String, Object?>>[instance.pkg];
    infoProps = <String, Object?>{};

    for (var i = 0; i < infoSpreadLevels.length; i += 1) {
      infoProps.addAll(infoSpreadLevels[i]);
    }

    info = Info(Options(props: infoProps));
  }

  final AppInstance instance;

  late Info info;

  bool current = false;

  late List<Map<String, Object?>> infoSpreadLevels;

  late Map<String, Object?> infoProps;

  @override
  void create() {
    createComponent(info);
  }

  @override
  void mount(Element target, Node? anchor) {
    mountComponent(info, target, anchor);
    current = true;
  }

  @override
  void update(List<int> dirty) {
    Props infoChanges;

    if (dirty[0] & 1 != 0) {
      var list = <Map<String, Object?>>[getSpreadProps(instance.pkg)];
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
  App component,
  Props props,
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

class AppInstance {
  AppInstance(List<Object?> instance) : _instance = instance;

  final List<Object?> _instance;

  Map<String, Object?> get pkg {
    return unsafeCast(_instance[0]);
  }
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
