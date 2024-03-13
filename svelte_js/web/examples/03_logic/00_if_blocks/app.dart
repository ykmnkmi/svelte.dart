// ignore_for_file: library_prefixes
library;

import 'dart:js_interop';

import 'package:svelte_js/internal.dart' as $;
import 'package:svelte_js/svelte_js.dart';
import 'package:web/web.dart';

import 'user.dart';

extension type AppProperties._(JSObject _) implements JSObject {
  AppProperties() : _ = JSObject();
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

  // Init
  var fragment = $.openFragment($anchor, true, _fragment);
  var node = $.childFragment<Comment>(fragment);
  var node1 = $.sibling<Comment>($.sibling<Text>(node, true));

  bool node$if$condition() {
    return $.get<User>(user).loggedIn;
  }

  void node$if$consequent(Node $anchor) {
    // Init
    var button = $.open<Element>($anchor, true, _template1);

    $.event<Event>('click', button, toggle, false);
    $.close($anchor, button);
  }

  $.ifBlock(node, node$if$condition, node$if$consequent, null);

  bool node1$if$condition() {
    return !$.get<User>(user).loggedIn;
  }

  void node1$if$consequent(Node $anchor) {
    // Init
    var button1 = $.open<Element>($anchor, true, _template2);

    $.event<Event>('click', button1, toggle, false);
    $.close($anchor, button1);
  }

  $.ifBlock(
    node1,
    node1$if$condition,
    node1$if$consequent,
    null,
  );

  $.closeFragment($anchor, fragment);
  $.pop();
}
