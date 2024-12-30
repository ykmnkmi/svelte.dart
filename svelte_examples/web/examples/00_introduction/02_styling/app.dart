import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart' show Element, Node;

void addCss(Element? target) {
  appendStyles(target, 'svelte-urs9w7', '''
p.svelte-urs9w7 {
  color: purple;
  font-family: 'Comic Sans MS', cursive;
  font-size: 2em;
}
''');
}

final class AppFragment extends Fragment {
  AppFragment(List<Object?> instance);

  late Element p;

  @override
  void create(List<Object?> instance) {
    p = element('p');
    setText(p, 'Styled!');
    setAttribute(p, 'class', 'svelte-urs9w7');
  }

  @override
  void mount(List<Object?> instance, Element target, Node? anchor) {
    insert(target, p, anchor);
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(p);
    }
  }
}

final class App extends Component {
  App({
    super.target,
    super.anchor,
    super.inputs,
    super.hydrate,
    super.intro,
  }) : super(createFragment: AppFragment.new, appendStyles: addCss);
}
