// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:svelte_ast/src/reflection.dart';
import 'package:svelte_ast/svelte_ast.dart';

const String string = '''
<script generics="T extends Object"></script>''';

void main() {
  Logger logger = Logger('parse');
  logger.onRecord.listen(print);

  try {
    Root root = parse(
      string,
      fileName: 'check.dart',
      uri: Uri.file('check.dart'),
      logger: logger,
    );

    Map<String, Object?> json = root.toJson(mapper);
    String output = const JsonEncoder.withIndent('  ').convert(json);
    File.fromUri(Uri(path: 'test/check.json')).writeAsStringSync(output);
  } on ParseError catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
    print(const JsonEncoder.withIndent('  ').convert(error.toJson()));
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}
