import 'package:svelte/src/runtime/component.dart';
import 'package:svelte/src/runtime/utilities.dart';

Component? currentComponent;

Component getCurrentComponent() {
  return unsafeCast(currentComponent);
}

void setCurrentComponent(Component? component) {
  currentComponent = component;
}
