import 'dart:convert';
import 'dart:io';

import 'package:nutty/compiler.dart';
import 'package:stack_trace/stack_trace.dart';

const JsonEncoder encoder = JsonEncoder.withIndent('  ');

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    exit(1);
  }

  var file = File(arguments.first);

  if (!file.existsSync()) {
    exit(2);
  }

  try {
    var content = file.readAsStringSync();
    var ast = parse(content);
    print(encoder.convert(ast.toJson()));
  } on ParseError catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
    print(encoder.convert(error.toJson()));
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}

// ignore_for_file: avoid_print
