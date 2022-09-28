import 'package:nutty/dom.dart';
import 'package:nutty/runtime.dart';

import 'nested.dart';

class IfBlock extends Fragment {
  IfBlock(this.component)
      : text1 = text(', click this button'),
        mounted = false;

  final App component;

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

  final App component;

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
  AppFragment(this.component, {required this.$zero})
      : button1 = element('button'),
        nested = Nested(count: component.count, $zero: $zero) {
    nested.on<int>('even').listen(component.log);
    nested.on<int>('odd').listen(component.log);
  }

  final App component;

  final Element button1;

  final Nested nested;

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
      listen<Event>(button1, 'click', component.handleClick);
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

    detachComponent(nested, detaching);
    cancel<Event>(button1, 'click', component.handleClick);
    mounted = false;
  }
}

class App extends Component {
  App({int count = 0}) : _count = count {
    _fragment = AppFragment(this, $zero: ZeroFragment(this));
  }

  int _count;

  AppFragment? _fragment;

  @override
  AppFragment get fragment {
    return unsafeCast<AppFragment>(_fragment);
  }

  int get count {
    return _count;
  }

  set count(int count) {
    invalidate('count', _count, _count = count);
  }

  void handleClick(Event event) {
    count += 1;
  }

  void log(CustomEvent<int> event) {
    console.log('${event.type}: ${event.detail}');
  }
}
