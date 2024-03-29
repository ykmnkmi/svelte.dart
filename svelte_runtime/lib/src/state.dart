import 'dart:html';

import 'package:svelte_runtime/src/fragment.dart';
import 'package:svelte_runtime/src/utilities.dart';

class State {
  Element? root;

  Fragment? fragment;

  bool destroyed = false;

  List<Object?> instance = <Object?>[];

  late List<int> dirty;

  VoidCallback update = noop;

  List<VoidFunction> onMount = <VoidFunction>[];

  List<VoidFunction> onDestroy = <VoidFunction>[];

  List<VoidFunction> beforeUpdate = <VoidFunction>[];

  List<VoidFunction> afterUpdate = <VoidFunction>[];
}
