import 'dart:js_interop';

import 'package:svelte_runtime/src/dom/operations.dart';
import 'package:web/web.dart';

DocumentFragment createFragment(String content) {
  HTMLTemplateElement element = createElement<HTMLTemplateElement>('template');
  element.innerHTML = content.toJS;
  return element.content;
}
