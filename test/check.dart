import 'dart:convert' show Converter, JsonEncoder;

import 'package:piko/compiler.dart';
import 'package:piko/src/compiler/interface.dart';
import 'package:stack_trace/stack_trace.dart' show Trace;

const String helloWorld = '<input use:tooltip={message}>';

const Converter<Object?, String> encoding = JsonEncoder.withIndent('  ');

void main() {
  try {
    AST ast = parse(helloWorld);
    Map<String, Object?> json = ast.toJson();
    print(encoding.convert(json));
    ast.html.children!.forEach(print);
  } catch (error, trace) {
    print(error);
    print(Trace.format(trace));
  }
}

// ignore_for_file: avoid_print
