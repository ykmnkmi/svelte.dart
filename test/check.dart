import 'dart:convert';

import 'package:piko/compiler.dart';
import 'package:stack_trace/stack_trace.dart';

void main() {
  try {
    var json = parse('<p>hello {name}!</p>').toJson();
    print(const JsonEncoder.withIndent(' ').convert(json));
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}
