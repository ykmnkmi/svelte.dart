// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:svelte_ast/svelte_ast.dart';

const String content = '''
<script>
  int count = 0;

  void onClick() {
    count += 1;
  }
</script>
<button on:click={onClick}>
  Count: {count}
</button>''';

void main() {
  // Create an AST tree by parsing an SvelteDart template.
  Root root = parse(content);

  // Print to console.
  print(const JsonEncoder.withIndent('  ').convert(root.toJson()));
}
