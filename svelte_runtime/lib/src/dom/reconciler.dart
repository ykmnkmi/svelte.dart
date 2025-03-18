import 'dart:js_interop';

import 'package:meta/dart2js.dart';
import 'package:svelte_runtime/src/dom/operations.dart';
import 'package:web/web.dart';

@noInline
DocumentFragment createFragment(String content) {
  HTMLTemplateElement element = createElement<HTMLTemplateElement>('template');
  element.innerHTML = content.toJS;
  return element.content;
}
