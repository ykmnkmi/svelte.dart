import 'dart:html';

import 'package:svelte/src/runtime/fragment.dart';

Set<Fragment> _outroing = <Fragment>{};

void transitionIn(Fragment? fragment, bool local) {
  if (fragment != null) {
    _outroing.remove(fragment);
    fragment.intro(local);
  }
}

void transitionOut(Fragment? fragment, bool local, [VoidCallback? callback]) {
  if (fragment != null) {
    if (_outroing.add(fragment)) {
      fragment.outro(local);
    }
  } else if (callback != null) {
    callback();
  }
}
