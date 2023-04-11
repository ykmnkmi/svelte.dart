import 'package:svelte/src/runtime/fragment.dart';
import 'package:web/web.dart';

class State {
  Fragment? fragment;

  late List<Object?> instance;

  late Map<String, int> props;

  late void Function() update;

  late int dirty;

  Element? root;
}
