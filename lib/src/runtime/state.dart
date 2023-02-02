import 'dart:html';

import 'package:svelte/src/runtime/fragment.dart';

// TODO(runtime): replace with records
class State {
  Fragment? fragment;

  late List<Object?> instance;

  late void Function() update;

  late List<int> dirty;

  Element? root;
}
