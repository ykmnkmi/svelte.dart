import 'package:meta/meta.dart';
import 'package:piko/dom.dart';
import 'package:piko/runtime.dart';
import 'package:piko/src/runtime/dispatcher.dart';

class NestedContext extends Context {
  NestedContext(this.component, {int count = 0}) : countValue = count;

  @override
  final Nested component;

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
        component.dispatch('even', detail: count);
      }

      if (count.isOdd) {
        component.dispatch('odd', detail: count);
      }
    }
  }
}

class ZeroFragment extends Fragment {
  ZeroFragment(this.context);

  final NestedContext context;

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
  NestedFragment(this.context, {this.zero})
      : button1 = element('button'),
        text1 = text('Clicked '),
        text2 = empty(),
        text3 = space(),
        text4 = empty(),
        text5 = text('!') {
    text4Data = text4Data_;
  }

  final NestedContext context;

  final Fragment? zero;

  final Element button1;

  final Text text1;

  final Text text2;

  final Text text3;

  final Text text4;

  final Text text5;

  String? text4Data;

  String get text4Data_ {
    return context.count == 1 ? 'time' : 'times';
  }

  @override
  void create() {
    setText(text2, context.count);
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
      setText(text2, context.count);
      diffText(text4, text4Data, text4Data = text4Data_);
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
  Nested({int count = 0, Fragment? zero}) {
    var context = NestedContext(this, count: count);
    var fragment = NestedFragment(context, zero: zero ?? ZeroFragment(context));
    this.context = context;
    this.fragment = fragment;
  }

  @override
  @pragma('dart2js:late:trust')
  late final NestedFragment fragment;

  @override
  @pragma('dart2js:late:trust')
  late final NestedContext context;
}
