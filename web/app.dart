import 'package:piko/dom.dart';
import 'package:piko/runtime.dart';

import 'nested.dart';

abstract class AppState extends Component {
  int _count = 0;

  int get countValue {
    return _count;
  }

  set countValue(int count) {
    invalidate('count', _count, _count = count);
  }

  void handleClickListener(Event event) {
    countValue += 1;
  }
}

class App extends AppState {
  final Element button1 = element('button');

  late final Nested nested;

  bool mounted = false;

  @override
  void create() {
    nested = Nested(count: countValue);
    nested.create();
  }

  @override
  void mount(Element target, Node? anchor) {
    insert(target, button1, anchor);
    nested.mount(button1, null);

    if (!mounted) {
      listen(button1, 'click', handleClickListener);
      mounted = true;
    }
  }

  @override
  void update(Set<String> dirty) {
    if (dirty.contains('count')) {
      nested.countValue = countValue;
    }
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(button1);
    }

    nested.detach(detaching);
    cancel(button1, 'click', handleClickListener);
    mounted = false;
  }
}
