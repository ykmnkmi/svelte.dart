import 'dart:convert';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:svelte/compiler.dart';

const JsonEncoder encoder = JsonEncoder.withIndent('  ');

const String content = '''
<script>
	var name;
</script>

<input bind:value={name}>
''';

void main() {
  try {
    var ast = parse(content);

    for (var child in ast.instance!.unit.childEntities) {
      if (child is TopLevelVariableDeclaration) {
        for (var variable in child.variables.variables) {
          print(variable);
        }
      }
    }

    // print(encoder.convert(ast.toJson()));
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
