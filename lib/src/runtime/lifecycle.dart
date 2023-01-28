import 'package:svelte/src/runtime/component.dart';
import 'package:svelte/src/runtime/utilities.dart';

Component? currentComponent;

Component getCurrentComponent() {
  assert(currentComponent != null);
  return unsafeCast(currentComponent);
}

void setCurrentComponent(Component? component) {
  currentComponent = component;
}
