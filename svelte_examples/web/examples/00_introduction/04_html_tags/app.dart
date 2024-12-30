import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart' show Element, Node;

extension on List<Object?> {
  String get _string {
    return this[0] as String;
  }
}

final class AppFragment extends Fragment {
  AppFragment(List<Object?> instance);

  late Element p;

  @override
  void create(List<Object?> instance) {
    p = element('p');
  }

  @override
  void mount(List<Object?> instance, Element target, Node? anchor) {
    insert(target, p, anchor);
    setInnerHtml(p, instance._string);
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
  var string = "here's some <strong>HTML!!!</strong>";
  return <Object?>[string];
}

final class App extends Component {
  App({
    super.target,
    super.anchor,
    super.inputs,
    super.hydrate,
    super.intro,
  }) : super(createInstance: createInstance, createFragment: AppFragment.new);
}
