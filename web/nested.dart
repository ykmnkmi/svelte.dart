import 'package:meta/meta.dart';
import 'package:piko/dom.dart';
import 'package:piko/runtime.dart';

class NestedContext extends Context {
  NestedContext(super.component, {int count = 0}) : countValue = count;

  @protected
  int countValue;

  int get count {
    return countValue;
  }

  set count(int value) {
    component.invalidate('count', countValue, countValue = value);
  }

  @override
  @protected
  void update(Set<String> dirty) {
    if (dirty.contains('count')) {
      if (count.isEven) {
        component.dispatch('even', count);
      }
    }
  }
}

class NestedFragment extends Fragment {
  NestedFragment(this.context);

  final NestedContext context;

  final Element button1 = element('button');

  final Text text1 = text('Clicked ');

  final Text text2 = empty();

  final Text text3 = space();

  final Text text4 = empty();

  String get text4Value {
    return context.count == 1 ? 'time' : 'times';
  }

  @override
  void create() {
    setText(text2, context.count);
    setText(text4, text4Value);
  }

  @override
  void mount(Element target, Node? anchor) {
    append(target, text1);
    append(target, text2);
    append(target, text3);
    append(target, text4);
  }

  @override
  void update(Set<String> dirty) {
    if (dirty.contains('count')) {
      setText(text2, context.count);
      setText(text4, text4Value);
    }
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(text1);
      remove(text2);
      remove(text3);
      remove(text4);
    }
  }
}

class Nested extends Component {
  Nested({int count = 0}) {
    context = NestedContext(this, count: count);
    fragment = NestedFragment(context);
  }

  @override
  late final NestedFragment fragment;

  @override
  late final NestedContext context;
}
