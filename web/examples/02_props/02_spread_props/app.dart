import 'dart:html';

import 'package:svelte/runtime.dart';

import 'info.dart';

Fragment createFragment(List<Object?> instance) {
  return AppFragment(instance);
}

class AppFragment extends Fragment {
  AppFragment(this.instance) {
    infoSpreadLevels = <Props>[instance[0] as Props];
    infoProps = <String, Object?>{};

    for (var i = 0; i < infoSpreadLevels.length; i += 1) {
      infoProps.addAll(infoSpreadLevels[i]);
    }

    info = Info(Options(props: infoProps));
  }

  final List<Object?> instance;

  late Info info;

  bool current = false;

  late List<Props> infoSpreadLevels;

  late Props infoProps;

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
  void update(List<Object?> instance, List<int> dirty) {
    Props infoChanges;

    if (dirty[0] & 1 != 0) {
      var list = <Props>[getSpreadProps(instance[0])];
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
