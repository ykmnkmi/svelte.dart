import 'package:svelte/src/runtime/fragment.dart';

typedef Instance = List<Object?>;

class State {
  State({
    this.fragment,
    required this.instance,
  });

  Fragment? fragment;

  Instance instance;
}
