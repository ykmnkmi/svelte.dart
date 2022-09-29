import 'package:nutty/dom.dart';
import 'package:nutty/runtime.dart';

class ZeroFragment extends Fragment {
  ZeroFragment(this.component);

  final Nested component;

  final Text text1 = text(', click it');

  @override
  void mount(Element target, Node? anchor) {
    insert(target, text1, anchor);
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(text1);
    }
  }
}

class NestedFragment extends Fragment {
  NestedFragment(this.component, {this.zero})
      : button1 = element('button'),
        text1 = text('Clicked '),
        text2 = empty(),
        text3 = space(),
        text4 = empty(),
        text5 = text('!');

  final Nested component;

  final Fragment? zero;

  final Element button1;

  final Text text1;

  final Text text2;

  final Text text3;

  final Text text4;

  final Text text5;

  String get text4Data {
    return component.count == 1 ? 'time' : 'times';
  }

  @override
  void create() {
    setText(text2, component.count);
    setText(text4, text4Data);
    zero?.create();
  }

  @override
  void mount(Element target, Node? anchor) {
    append(target, text1);
    append(target, text2);
    append(target, text3);
    append(target, text4);
    zero?.mount(target, anchor);
    append(target, text5);
  }

  @override
  void update(Set<String> dirty) {
    if (dirty.contains('count')) {
      setText(text2, component.count);
      setText(text4, text4Data);
    }
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(text1);
      remove(text2);
      remove(text3);
      remove(text4);
      zero?.detach(detaching);
      remove(text5);
    }
  }
}

class Nested extends Component with Dispatcher {
  Nested({int count = 0, Fragment? $zero}) : _count = count {
    _fragment = NestedFragment(this, zero: $zero ?? ZeroFragment(this));
  }

  int _count;

  NestedFragment? _fragment;

  @override
  NestedFragment get fragment {
    return unsafeCast<NestedFragment>(_fragment);
  }

  int get count {
    return _count;
  }

  set count(int count) {
    invalidate('count', _count, _count = count);
  }

  @override
  void afterChanges() {
    if (dirty.contains('count')) {
      if (count.isEven) {
        dispatch('even', detail: count);
      } else {
        dispatch('odd', detail: count);
      }
    }
  }
}
