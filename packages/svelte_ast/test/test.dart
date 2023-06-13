// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:stack_trace/stack_trace.dart';
import 'package:svelte_ast/svelte_ast.dart';

const String template = '''
{#if true}
  then: {'then'}
{:else if false}
  else: {'else'}
{/if}''';

void main() {
  try {
    Node ast = parse(template, uri: Uri.file('main.dart'));
    Map<String, Object?> json = ast.toJson();
    String output = const JsonEncoder.withIndent('  ').convert(json);
    File('test/test.json').writeAsStringSync(output);
  } on ParseError catch (error, stackTrace) {
    print(error);
    print(error.span.highlight());
    print(Trace.format(stackTrace));
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}
