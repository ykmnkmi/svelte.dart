import 'package:svelte_runtime/src/fragment.dart';
import 'package:svelte_runtime/src/utilities.dart';
import 'package:web/web.dart' show Element;

class State {
  Element? root;

  Fragment? fragment;

  bool destroyed = false;

  List<Object?> instance = <Object?>[];

  int dirty = -1;

  void Function(State state) update = noop;

  List<VoidFunction> onMount = <VoidFunction>[];

  List<VoidFunction> onDestroy = <VoidFunction>[];

  List<VoidFunction> beforeUpdate = <VoidFunction>[];

  List<VoidFunction> afterUpdate = <VoidFunction>[];
}
