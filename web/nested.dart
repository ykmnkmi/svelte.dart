import 'package:piko/dom.dart';
import 'package:piko/runtime.dart';

abstract class NestedState extends Component {
  NestedState({int count = 0}) : _count = count;

  int _count = 0;

  int get countValue {
    return _count;
  }

  set countValue(int count) {
    invalidate('count', _count, _count = count);
  }
}

class Nested extends NestedState {
  Nested({super.count});

  final Element button1 = element('button');

  final Text text1 = text('Clicked ');

  final Text text2 = empty();

  final Text text3 = space();

  final Text text4 = empty();

  String get text4Value {
    return countValue == 1 ? 'time' : 'times';
  }

  @override
  void create() {
    setText(text2, countValue);
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
      setText(text2, countValue);
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
