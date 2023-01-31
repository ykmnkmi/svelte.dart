// TODO(runtime): replace with records
import 'dart:html';

import 'package:svelte/src/runtime/component.dart';
import 'package:svelte/src/runtime/fragment.dart';

class State {
  Fragment? fragment;

  late Instance instance;

  late VoidCallback update;

  late int dirty;

  Element? root;
}
