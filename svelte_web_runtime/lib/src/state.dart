import 'dart:html';

import 'package:svelte_web_runtime/src/fragment.dart';

class State {
  Fragment? fragment;

  late List<Object?> instance;

  late Map<String, int> props;

  late void Function() update;

  late int dirty;

  Element? root;
}
