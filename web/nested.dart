import 'package:meta/meta.dart';
import 'package:piko/dom.dart';
import 'package:piko/runtime.dart';
import 'package:piko/src/runtime/dispatcher.dart';
import 'package:piko/src/runtime/scope.dart';

class NestedContext extends Context {
  NestedContext(this.component, {int count = 0}) : countValue = count;

  @override
  final Nested component;

  Scope? $scope;

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

      if (count.isOdd) {
        component.dispatch('odd', count);
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
  NestedFragment(this.context, {this.$zero});

  final NestedContext context;

  final Fragment? $zero;

  final Element button1 = element('button');

  final Text text1 = text('Clicked ');

  final Text text2 = empty();

  final Text text3 = space();

  final Text text4 = empty();

  final Text text5 = text('!');

  String get text4Value {
    return context.count == 1 ? 'time' : 'times';
  }

  @override
  void create() {
    setText(text2, context.count);
    setText(text4, text4Value);

    var $zero = this.$zero;

    if ($zero != null) {
      $zero.create();
    }
  }

  @override
  void mount(Element target, Node? anchor) {
    append(target, text1);
    append(target, text2);
    append(target, text3);
    append(target, text4);

    var $zero = this.$zero;

    if ($zero != null) {
      $zero.mount(target, anchor);
    }

    append(target, text5);
  }

  @override
  void update(Set<String> dirty) {
    if (dirty.contains('count')) {
      setText(text2, context.count);
      setText(text4, text4Value);
    }

    var $zero = this.$zero;

    if ($zero != null) {
      $zero.update(context.$scope!.dirty);
    }
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(text1);
      remove(text2);
      remove(text3);
      remove(text4);

      var $zero = this.$zero;

      if ($zero != null) {
        $zero.detach(detaching);
      }

      remove(text5);
    }
  }
}

class Nested extends Component with Dispatcher {
  Nested({int count = 0, Slot? $zero}) {
    context = NestedContext(this, count: count);
    fragment = NestedFragment(context, $zero: $zero ?? ZeroSlot(this));
  }

  @override
  @pragma('dart2js:late:trust')
  late NestedFragment fragment;

  @override
  @pragma('dart2js:late:trust')
  late NestedContext context;
}
