import 'package:meta/meta.dart';
import 'package:svelte_runtime/src/component.dart';

@internal
Component? currentComponent;

Component getCurrentComponent() {
  return currentComponent!;
}

void setCurrentComponent(Component? component) {
  currentComponent = component;
}
