import 'dart:convert';

import 'package:stack_trace/stack_trace.dart';
import 'package:svelte/compiler.dart';

const JsonEncoder encoder = JsonEncoder.withIndent('  ');

const String content = '''
<style>
	this is not css
</style>
''';

void main() {
  try {
    var ast = parse(content);
    print(encoder.convert(ast.toJson()));
  } on ParseError catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
    print(encoder.convert(error.toJson()));
    print('');
    print(error.span.highlight());
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}

// ignore_for_file: avoid_print
