@JS(r'$$')
library;

import 'dart:js_interop';

import 'package:web/web.dart';

@JS('child')
external T child<T extends JSObject>(Node node);

@JS('child_frag')
external T childFragment<T extends JSObject>(Node node);

@JS('sibling')
external T sibling<T extends JSObject>(Node node);
