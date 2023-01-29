import 'dart:html';

import 'package:svelte/src/runtime/component.dart';
import 'package:svelte/src/runtime/fragment.dart';

typedef InstanceFactory<T extends Component> = Instance Function(T component);

typedef Instance = List<Object?>;

class State {
  Fragment? fragment;

  Instance instance = <Object?>[];

  Element? root;
}
