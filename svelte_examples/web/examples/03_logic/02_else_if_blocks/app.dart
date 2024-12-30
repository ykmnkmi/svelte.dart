import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart' show Element, Node;

final class ElseBlockFragment extends Fragment {
  ElseBlockFragment(List<Object?> instance);

  late Element p;

  @override
  void create(List<Object?> instance) {
    p = element('p');
    setText(p, '$x is between 5 and 10');
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

final class IfBlock1Fragment extends Fragment {
  IfBlock1Fragment(List<Object?> instance);

  late Element p;

  @override
  void create(List<Object?> instance) {
    p = element('p');
    setText(p, '$x is less than 5');
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

final class IfBlockFragment extends Fragment {
  IfBlockFragment(List<Object?> instance);

  late Element p;

  @override
  void create(List<Object?> instance) {
    p = element('p');
    setText(p, '$x is greater than 10');
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

final class AppFragment extends Fragment {
  AppFragment(List<Object?> instance) {
    currentBlockFactory = selectCurrentBlock(instance, -1);
    ifBlock = currentBlockFactory(instance);
  }

  late Node ifBlockAnchor;

  FragmentFactory selectCurrentBlock(List<Object?> context, int dirty) {
    if (x > 10) {
      return IfBlockFragment.new;
    }

    if (5 > x) {
      return IfBlock1Fragment.new;
    }

    return ElseBlockFragment.new;
  }

  late FragmentFactory currentBlockFactory;

  late Fragment ifBlock;

  @override
  void create(List<Object?> instance) {
    ifBlock.create(instance);
    ifBlockAnchor = empty();
  }

  @override
  void mount(List<Object?> instance, Element target, Node? anchor) {
    ifBlock.mount(instance, target, anchor);
    insert(target, ifBlockAnchor, anchor);
  }

  @override
  void update(List<Object?> instance, int dirty) {}

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(ifBlockAnchor);
    }

    ifBlock.detach(detaching);
  }
}

var x = 7;

final class App extends Component {
  App({
    super.target,
    super.anchor,
    super.properties,
    super.hydrate,
    super.intro,
  }) : super(createFragment: AppFragment.new);
}
