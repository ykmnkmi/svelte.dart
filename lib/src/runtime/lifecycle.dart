import 'package:svelte/src/runtime/component.dart';

Component? currentComponent;

Component getCurrentComponent() {
  assert(currentComponent != null);
  return currentComponent as Component;
}

void setCurrentComponent(Component? component) {
  currentComponent = component;
}
