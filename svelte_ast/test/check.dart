// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:stack_trace/stack_trace.dart';
import 'package:svelte_ast/svelte_ast.dart';

const String string = '''
<script context="module">
  import 'dart:math';

	final name = 'Svelte \$pi';
</script>
''';

void main() {
  try {
    SvelteAst ast = parse(
      string,
      fileName: 'check.dart',
      uri: Uri.file('check.dart'),
    );

    Map<String, Object?> json = ast.toJson();
    String output = const JsonEncoder.withIndent('\t').convert(json);
    File.fromUri(Uri(path: 'test/check.json')).writeAsStringSync(output);
  } on ParseError catch (error, stackTrace) {
    print(error);
    print(error.span.highlight());
    print(Trace.format(stackTrace));
    print(const JsonEncoder.withIndent('\t').convert(error.toJson()));
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}
