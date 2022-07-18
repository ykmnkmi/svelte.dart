import 'package:piko/dom.dart';
import 'package:piko/runtime.dart';

import 'nested.dart';

mixin AppState on Component {
  int countValue = 0;

  int get $count {
    return countValue;
  }

  set $count(int count) {
    invalidate('count', countValue, countValue = count);
  }

  void $handleClick(Event event) {
    $count += 1;
  }
}

class App extends Component with AppState {
  final Element button1 = element('button');

  final Nested nested = Nested();

  bool mounted = false;

  @override
  void create() {
    nested.countValue = countValue;
    nested.create();
  }

  @override
  void mount(Element target, Node? anchor) {
    insert(target, button1, anchor);
    nested.mount(button1, null);

    if (!mounted) {
      listen(button1, 'click', $handleClick);
      mounted = true;
    }
  }

  @override
  void update(Set<String> dirty) {
    if (dirty.contains('count')) {
      nested.$count = $count;
    }
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(button1);
    }

    nested.detach(detaching);
    cancel(button1, 'click', $handleClick);
    mounted = false;
  }
}
