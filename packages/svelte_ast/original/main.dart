import 'dart:convert';
import 'dart:io';

import 'package:stack_trace/stack_trace.dart';

import 'parser.dart';

const String string = '''
{#each users as user, index (user.id)}
  {index}: {user.name}
{:else}
  empty list
{/each}''';

void main() {
  try {
    Parser parser = Parser(string, uri: Uri.file('main.dart'));
    Map<String, Object?> json = parser.html.toJson();
    String output = const JsonEncoder.withIndent('  ').convert(json);
    File('original/main.json').writeAsStringSync(output);
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}
