// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:stack_trace/stack_trace.dart';
import 'package:svelte_ast/svelte_ast.dart';

const JsonEncoder encoder = JsonEncoder.withIndent('  ');

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    exit(1);
  }

  File file = File(arguments.first);

  if (file.existsSync()) {
    try {
      String content = file.readAsStringSync();
      SvelteAst ast = parse(content);
      Map<String, Object?> json = ast.toJson();
      print(encoder.convert(json));
    } on ParseError catch (error, stackTrace) {
      print(error.errorCode.message);
      print(error.span.highlight(color: true));
      print(Trace.format(stackTrace));
    } catch (error, stackTrace) {
      print(error);
      print(Trace.format(stackTrace));
    }
  } else {
    exit(2);
  }
}
