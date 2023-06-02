// ignore_for_file: avoid_print, depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:stack_trace/stack_trace.dart';
import 'package:svelte_ast/src/ast.dart';

import 'parser.dart';

const String source = '''
{#await future catch error}
  {error}
{/await}''';

void main() {
  try {
    Node ast = parse(source);
    Map<String, Object?> json = ast.toJson();
    File file = File('experiments/main.json');
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(json));
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}
