import 'dart:convert';
import 'dart:io';

import 'package:piko/compiler.dart';
import 'package:stack_trace/stack_trace.dart';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    exit(1);
  }

  try {
    var source = File(arguments.first).readAsStringSync();
    var json = parse(source).toJson();
    print(const JsonEncoder.withIndent('  ').convert(json));
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}
