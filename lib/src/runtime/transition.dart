import 'dart:html';

import 'package:svelte/src/runtime/component.dart';
import 'package:svelte/src/runtime/fragment.dart';

Set<Fragment> _outroing = <Fragment>{};

void transitionInComponent(Component component, bool local) {
  var fragment = component.state.fragment;

  if (fragment != null) {
    _outroing.remove(fragment);
    fragment.intro(local);
  }
}

void transitionOutComponent(
  Component component,
  bool local, [
  VoidCallback? callback,
]) {
  var fragment = component.state.fragment;

  if (fragment != null) {
    if (_outroing.add(fragment)) {
      fragment.outro(local);
    }
  } else if (callback != null) {
    callback();
  }
}
