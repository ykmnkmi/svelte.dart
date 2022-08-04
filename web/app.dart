import 'package:meta/meta.dart';
import 'package:piko/dom.dart';
import 'package:piko/runtime.dart';

import 'nested.dart';

class AppContext extends Context {
  AppContext(this.component, {int count = 0}) : countValue = count;

  @override
  final App component;

  @protected
  int countValue;

  int get count {
    return countValue;
  }

  set count(int value) {
    component.invalidate('count', countValue, countValue = value);
  }

  void handleClick(Event event) {
    count += 1;
  }

  void log(CustomEvent<int> event) {
    console.log('${event.type}: ${event.detail}');
    // console.log(event);
  }
}

class IfBlock extends Fragment {
  IfBlock(this.context)
      : text1 = text(', click this button'),
        mounted = false;

  final AppContext context;

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
  ZeroFragment(this.context)
      : ifBlock1Anchor = empty(),
        ifBlock1 = IfBlock(context);

  final AppContext context;

  final Text ifBlock1Anchor;

  final IfBlock ifBlock1;

  @override
  void create() {
    if (context.count == 0) {
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
        if (context.count == 0) {
          var target = unsafeCast<Element>(parentElement(ifBlock1Anchor));
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
  AppFragment(this.context, this.zero)
      : button1 = element('button'),
        nested = Nested(count: context.count, $zero: zero) {
    nested.on<int>('even').listen(context.log);
    nested.on<int>('odd').listen(context.log);
  }

  final AppContext context;

  final Element button1;

  final Nested nested;

  final ZeroFragment zero;

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
      listen(button1, 'click', context.handleClick);
      mounted = true;
    }
  }

  @override
  void update(Set<String> dirty) {
    if (dirty.contains('count')) {
      nested.context.count = context.count;
    }

    zero.update(dirty);
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(button1);
    }

    detachComponent(nested, detaching);
    cancel(button1, 'click', context.handleClick);
    mounted = false;
  }
}

class App extends Component {
  App({int count = 0}) {
    var context = AppContext(this, count: count);
    var fragment = AppFragment(context, ZeroFragment(context));
    this.context = context;
    this.fragment = fragment;
  }

  @override
  @pragma('dart2js:late:trust')
  late final AppFragment fragment;

  @override
  @pragma('dart2js:late:trust')
  late final AppContext context;
}
