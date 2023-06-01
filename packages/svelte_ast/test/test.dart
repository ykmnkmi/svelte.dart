// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:stack_trace/stack_trace.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/svelte_ast.dart';

const String template = '''
{#await promise}
	...waiting
{:then number}
	{number}
{:catch error}
	{error.message}
{/await}
''';

void main() {
  try {
    var ast = parse(template);
    var json = ast.toJson();
    print(const JsonEncoder.withIndent('  ').convert(json));
  } on ParseError catch (error, stackTrace) {
    print(error);
    print(error.span.highlight());
    print(Trace.format(stackTrace));
  }
}
