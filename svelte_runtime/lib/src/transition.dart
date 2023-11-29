import 'package:meta/dart2js.dart';
import 'package:meta/meta.dart';
import 'package:svelte_runtime/src/fragment.dart';
import 'package:svelte_runtime/src/utilities.dart';

@internal
Set<Fragment> outroing = <Fragment>{};

@noInline
void transitionIn(Fragment? fragment, bool local) {
  if (fragment != null) {
    outroing.remove(fragment);
    fragment.intro(local);
  }
}

@noInline
void transitionOut(
  Fragment? fragment,
  bool local, [
  VoidFunction? callback,
]) {
  if (fragment != null) {
    if (outroing.add(fragment)) {
      fragment.outro(local);
    }
  } else if (callback != null) {
    callback();
  }
}
