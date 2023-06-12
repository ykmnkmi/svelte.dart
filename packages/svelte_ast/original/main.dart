import 'dart:convert';

import 'package:stack_trace/stack_trace.dart';

import 'parser.dart';

const String string = '''
{#key 1}
  {@const name = 'world'}
  {@debug name}
  hello {@html name}!
{/key}''';

void main() {
  try {
    Parser parser = Parser(string, uri: Uri.file('main.dart'));
    Map<String, Object?> json = parser.html.toJson();
    print(const JsonEncoder.withIndent('  ').convert(json));
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}
