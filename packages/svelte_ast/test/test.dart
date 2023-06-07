// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:stack_trace/stack_trace.dart';
import 'package:svelte_ast/svelte_ast.dart';

const String template = '''
<h1>hello {name}!</h1>''';

void main() {
  try {
    var ast = parse(template);
    var json = ast.toJson();
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
