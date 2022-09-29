import 'dart:html';

import 'package:meta/meta.dart';
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

  String get text2Data {
    return '${component.count}';
  }

  String get text4Data {
    return component.count == 1 ? 'time' : 'times';
  }

  @override
  void create() {
    setText(text2, '${component.count}');
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
      setText(text2, text2Data);
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

class NestedContext {
  NestedContext({required this.count});

  int count;
}

class Nested extends Component<NestedContext> with Dispatcher {
  Nested({int count = 0, Fragment? $zero}) : super(NestedContext(count: count)) {
    fragment = NestedFragment(this, zero: $zero ?? ZeroFragment(this));
  }

  @nonVirtual
  @override
  @pragma('dart2js:late:trust')
  late NestedFragment fragment;

  int get count {
    return context.count;
  }

  set count(int count) {
    invalidate('count', context.count, context.count = count);
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
