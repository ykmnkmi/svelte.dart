import 'dart:html';

import 'package:svelte_runtime/svelte_runtime.dart';

extension on List<Object?> {
  String get _string {
    return this[0] as String;
  }
}

Fragment createFragment(List<Object?> instance) {
  late Element p;

  return Fragment(
    create: () {
      p = element('p');
    },
    mount: (Element target, Node? anchor) {
      insert(target, p, anchor);
      setInnerHtml(p, instance._string);
    },
    detach: (bool detaching) {
      if (detaching) {
        detach(p);
      }
    },
  );
}

List<Object?> createInstance(
  Component self,
  Map<String, Object?> props,
  Invalidate invalidate,
) {
  var string = "here's some <strong>HTML!!!</strong>";
  return <Object?>[string];
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
