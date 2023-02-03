import 'package:meta/dart2js.dart';
import 'package:svelte/src/runtime/fragment.dart';

Set<Fragment> _outroing = <Fragment>{};

@noInline
void transitionIn(Fragment? fragment, bool local) {
  if (fragment != null) {
    _outroing.remove(fragment);
    fragment.intro(local);
  }
}

@noInline
void transitionOut(
  Fragment? fragment,
  bool local, [
  void Function()? callback,
]) {
  if (fragment != null) {
    if (_outroing.add(fragment)) {
      fragment.outro(local);
    }
  } else if (callback != null) {
    callback();
  }
}
