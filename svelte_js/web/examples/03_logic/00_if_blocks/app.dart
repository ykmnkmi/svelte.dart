import 'dart:js_interop';

import 'package:svelte_js/internal.dart' as $; // ignore: library_prefixes
import 'package:svelte_js/svelte_js.dart';
import 'package:web/web.dart';

import 'user.dart';

extension type AppProperties._(JSObject object) implements JSObject {
  AppProperties() : object = JSObject();
}

extension type const App._(Component<AppProperties> component) {
  void call(Node node) {
    component(node, AppProperties());
  }
}

const App app = App._(_component);

final _template1 = $.template('<button>Log out</button>');
final _template2 = $.template('<button>Log in</button>');
final _fragment = $.fragment('<!> <!>');

void _component(Node $anchor, AppProperties $properties) {
  $.push($properties, false);

  var user = $.mutableSource<User>(User(loggedIn: false));

  void toggle(Event event) {
    $.mutate(user, $.get<User>(user).loggedIn = !$.get<User>(user).loggedIn);
  }

  $.init();

  /* Init */
  var fragment = $.openFragment($anchor, true, _fragment);
  var node = $.childFragment<Comment>(fragment);
  var node1 = $.sibling<Comment>($.sibling<Text>(node, true));

  $.ifBlock(node, () => $.get<User>(user).loggedIn, ($anchor) {
    /* Init */
    var button = $.open<Element>($anchor, true, _template1);

    $.event<Event>('click', button, toggle, false);
    $.close($anchor, button);
  });

  $.ifBlock(node1, () => !$.get<User>(user).loggedIn, ($anchor) {
    /* Init */
    var button1 = $.open<Element>($anchor, true, _template2);

    $.event<Event>('click', button1, toggle, false);
    $.close($anchor, button1);
  });

  $.closeFragment($anchor, fragment);
  $.pop();
}
