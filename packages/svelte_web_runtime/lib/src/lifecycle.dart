import 'package:svelte_web_runtime/src/component.dart';

Component? currentComponent;

Component getCurrentComponent() {
  return currentComponent!;
}

void setCurrentComponent(Component? component) {
  currentComponent = component;
}
