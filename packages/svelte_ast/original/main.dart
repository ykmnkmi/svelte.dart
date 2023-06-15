// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:stack_trace/stack_trace.dart';
import 'package:svelte_ast/src/errors.dart';

import 'parser.dart';

const String string = '''
{#if ok}
  <textarea>hello {name}!</textarea>
{/if}''';

void main() {
  try {
    Parser parser = Parser(string: string, uri: Uri.file('main.dart'));
    Map<String, Object?> json = parser.html.toJson();
    String output = const JsonEncoder.withIndent('  ').convert(json);
    File('original/main.json').writeAsStringSync(output);
  } on ParseError catch (error, stackTrace) {
    print(error);
    print(error.span.highlight());
    print(Trace.format(stackTrace));
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}
