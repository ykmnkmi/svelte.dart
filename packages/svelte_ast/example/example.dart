import 'dart:convert';

import 'package:svelte_ast/svelte_ast.dart';

const String content = '''
<script>
  var count = 0;
</script>
<button on:click="{() => count++}">count: {count}</button>''';

void main() {
  // Create an AST tree by parsing an SvelteDart template.
  SvelteAst ast = parse(content);

  // Print to console.
  print(const JsonEncoder.withIndent('  ').convert(ast.toJson()));
}
