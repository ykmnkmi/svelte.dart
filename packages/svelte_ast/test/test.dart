// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:stack_trace/stack_trace.dart';
import 'package:svelte_ast/svelte_ast.dart';

const String template = '''
<p id="title">...</p>''';

void main() {
  try {
    Node ast = parse(template);
    Map<String, Object?> json = ast.toJson();
    print(const JsonEncoder.withIndent('  ').convert(json));
  } on ParseError catch (error, stackTrace) {
    print(error);
    print(error.span.highlight());
    print(Trace.format(stackTrace));
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}
