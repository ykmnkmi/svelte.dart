import 'package:meta/meta.dart';
import 'package:piko/dom.dart';
import 'package:piko/runtime.dart';

import 'nested.dart';

class AppContext extends Context {
  AppContext(super.component, {int count = 0}) : countValue = count;

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
    print(event.detail);
  }
}

class AppFragment extends Fragment {
  AppFragment(this.context) {
    nested = Nested(count: context.count);
    nested.on<int>('even').listen(context.log);
  }

  final AppContext context;

  final Element button1 = element('button');

  late final Nested nested;

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
  late final AppFragment fragment;

  @override
  late final AppContext context;
}
