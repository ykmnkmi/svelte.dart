// ignore_for_file: avoid_print

import 'dart:html';

import 'package:svelte/runtime.dart';

import 'nested.dart';

class IfBlock extends Fragment {
  IfBlock(this.component)
      : text1 = text(', click this button'),
        mounted = false;

  final AppComponent component;

  final Text text1;

  bool mounted;

  @override
  void mount(Element target, Node? anchor) {
    insert(target, text1, anchor);
    mounted = true;
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(text1);
    }
  }
}

class ZeroFragment extends Fragment {
  ZeroFragment(this.component)
      : ifBlock1Anchor = empty(),
        ifBlock1 = IfBlock(component);

  final AppComponent component;

  final Text ifBlock1Anchor;

  final IfBlock ifBlock1;

  @override
  void create() {
    if (component.count == 0) {
      ifBlock1.create();
    }
  }

  @override
  void mount(Element target, Node? anchor) {
    ifBlock1.mount(target, anchor);
    insert(target, ifBlock1Anchor, anchor);
  }

  @override
  void update(Set<String> dirty) {
    if (dirty.contains('count')) {
      var ifBlock1 = this.ifBlock1;

      if (ifBlock1.mounted) {
        ifBlock1.detach(true);
      } else {
        if (component.count == 0) {
          var target = unsafeCast<Element>(ifBlock1Anchor.parent);
          ifBlock1.create();
          ifBlock1.mount(target, ifBlock1Anchor);
        }
      }
    }
  }

  @override
  void detach(bool detaching) {
    ifBlock1.detach(detaching);

    if (detaching) {
      remove(ifBlock1Anchor);
    }
  }
}

class AppFragment extends Fragment {
  AppFragment(this.component, {required this.$zero})
      : button1 = element<ButtonElement>('button'),
        button1ClickListener = eventListener(component.handleClick),
        nested = NestedComponent(count: component.count, $zero: $zero) {
    nested.on<int>('even').listen(component.logEven);
    nested.on<int>('odd').listen(component.logOdd);
  }

  final AppComponent component;

  final ButtonElement button1;

  final EventListener button1ClickListener;

  final NestedComponent nested;

  final ZeroFragment $zero;

  bool mounted = false;

  @override
  void create() {
    createComponent(nested);
  }

  @override
  void mount(Element target, Node? anchor) {
    insert(target, button1, anchor);
    mountComponent(nested, button1, null);

    if (!mounted) {
      listen(button1, 'click', button1ClickListener);
      mounted = true;
    }
  }

  @override
  void update(Set<String> dirty) {
    if (dirty.contains('count')) {
      nested.count = component.count;
    }

    $zero.update(dirty);
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(button1);
    }

    destroyComponent(nested, detaching);
    cancel(button1, 'click', button1ClickListener);
    mounted = false;
  }
}

abstract class App implements Component {
  factory App({int count}) = AppComponent;

  abstract int count;

  void handleClick();

  void logEven(int count);

  void logOdd(int count);
}

class AppContext {
  AppContext({required this.count});

  int count;
}

class AppComponent extends Component implements App {
  AppComponent({int count = 0}) : context = AppContext(count: count) {
    fragment = AppFragment(this, $zero: ZeroFragment(this));
  }

  final AppContext context;

  @override
  @pragma('dart2js:late:trust')
  late AppFragment fragment;

  @override
  int get count {
    return context.count;
  }

  @override
  set count(int count) {
    invalidate('count', context.count, context.count = count);
  }

  @override
  void handleClick() {
    count += 1;
  }

  @override
  void logEven(int count) {
    print('even: $count');
  }

  @override
  void logOdd(int count) {
    print('odd: $count');
  }
}
