import 'package:piko/piko.dart';

class Nested extends Component<Nested> {
  @override
  Fragment<Nested> render(RenderTree tree) {
    return NestedFragment(this, tree);
  }
}

class NestedFragment extends Fragment<Nested> {
  NestedFragment(Nested context, RenderTree tree) : super(context, tree);

  late Element b1;

  @override
  void create() {
    b1 = element('b');
    b1.text = 'paragraph';
  }

  @override
  void mount(Element target, [Node? anchor]) {
    insert(target, b1, anchor);
  }

  @override
  void detach([bool detaching = false]) {
    if (detaching) {
      remove(b1);
    }
  }
}
