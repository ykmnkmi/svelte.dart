import 'package:svelte/src/runtime/component.dart';

Component? currentComponent;

Component getCurrentComponent() {
  return currentComponent!;
}

void setCurrentComponent(Component? component) {
  currentComponent = component;
}
