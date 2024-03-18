// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:stack_trace/stack_trace.dart';
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/reflection.dart';

import 'parser.dart';

const String string = '''
<p class:isRed={true}>hello {name}!</p>''';

void main() {
  try {
    Node node = parse(string, uri: Uri.file('main.dart'));
    Map<String, Object?> json = node.toJson(mapper);
    String output = const JsonEncoder.withIndent('  ').convert(json);
    print(output);
  } on ParseError catch (error, stackTrace) {
    print(error);
    print(error.span.highlight());
    print(Trace.format(stackTrace));
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}

Node parse(String source, {String? fullName, Uri? uri}) {
  return Parser(source, fullName: fullName, uri: uri).parse();
}
