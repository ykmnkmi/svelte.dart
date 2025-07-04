import 'package:web/web.dart';

void toggleClass(Element element, String className, bool value) {
  if (value) {
    if (!element.classList.contains(className)) {
      element.classList.add(className);
    }
  } else {
    if (element.classList.contains(className)) {
      element.classList.remove(className);
    }
  }
}
