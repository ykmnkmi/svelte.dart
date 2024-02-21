import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart';

void nodeValue(Node node, String value) {
  node.setProperty('nodeValue'.toJS, value.toJS);
}
