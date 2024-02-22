@JS(r'$$')
library;

import 'dart:js_interop';

import 'package:web/web.dart';

@JS('child')
external T child<T extends Node>(Node node);

@JS('child_frag')
external T childFragment<T extends Node>(Node node, [bool isText]);

@JS('sibling')
external T sibling<T extends Node>(Node node);
