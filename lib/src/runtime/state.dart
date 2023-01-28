import 'dart:html';

import 'package:svelte/src/runtime/fragment.dart';

typedef Instance = List<Object?>;

class State {
  Fragment? fragment;

  Instance? instance;

  Element? root;
}
