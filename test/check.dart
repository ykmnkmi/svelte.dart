import 'dart:convert';
import 'dart:io';

import 'package:piko/compiler.dart';
import 'package:stack_trace/stack_trace.dart';

const JsonEncoder encoder = JsonEncoder.withIndent('  ');
void main(List<String> arguments) {
  if (arguments.isEmpty) {
    exit(1);
  }

  try {
    var source = File(arguments.first).readAsStringSync();
    var ast = parse(source);
    print(encoder.convert(ast.toJson()));
  } on CompileError catch (error) {
    print(encoder.convert(error.toJson()));
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}
