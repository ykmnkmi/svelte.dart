import 'package:meta/meta.dart';
import 'package:piko/dom.dart';
import 'package:piko/runtime.dart';
import 'package:piko/src/runtime/scope.dart';

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
    // console.log('${event.type}: ${event.detail}');
    console.log(event);
  }
}

class IfBlock extends Fragment {
  final Text text1 = text(', click this button');

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

class ZeroFragment extends Fragment {
  ZeroFragment(this.context);

  final AppContext context;

  final Text ifBlock1Anchor = empty();

  IfBlock? ifBlock1;

  @override
  void create() {
    if (context.count == 0) {
      var ifBlock1 = IfBlock();
      ifBlock1.create();
      this.ifBlock1 = ifBlock1;
    }
  }

  @override
  void mount(Element target, Node? anchor) {
    var ifBlock1 = this.ifBlock1;

    if (ifBlock1 != null) {
      ifBlock1.mount(target, anchor);
    }

    insert(target, ifBlock1Anchor, anchor);
  }

  @override
  void update(Set<String> dirty) {
    if (dirty.contains('count')) {
      var ifBlock1 = this.ifBlock1;

      if (ifBlock1 == null) {
        if (context.count == 0) {
          ifBlock1 = IfBlock();
          ifBlock1.create();

          var target = unsafeCast<Element>(parentElement(ifBlock1Anchor));
          ifBlock1.mount(target, ifBlock1Anchor);
          this.ifBlock1 = ifBlock1;
        }
      } else {
        ifBlock1.detach(true);
        this.ifBlock1 == null;
      }
    }
  }

  @override
  void detach(bool detaching) {
    var ifBlock1 = this.ifBlock1;

    if (ifBlock1 != null) {
      ifBlock1.detach(detaching);
    }

    if (detaching) {
      remove(ifBlock1Anchor);
    }
  }
}

class AppFragment extends Fragment {
  AppFragment(this.context) {
    nested = Nested(count: context.count, $zero: ZeroFragment(context));
    nested.on<int>('even').listen(context.log);
    nested.on<int>('odd').listen(context.log);
  }

  final AppContext context;

  final Element button1 = element('button');

  @pragma('dart2js:late:trust')
  late Nested nested;

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
      nested.context.$scope = Scope(context, dirty);
    }
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
    context = AppContext(this, count: count);
    fragment = AppFragment(context);
  }

  @override
  @pragma('dart2js:late:trust')
  late AppFragment fragment;

  @override
  @pragma('dart2js:late:trust')
  late AppContext context;
}
