import 'dart:convert';

import 'package:svelte_ast/svelte_ast.dart';

void main() {
  // Create an AST tree by parsing an SvelteDart template.
  var node = parse('<button title={someTitle}>Hello World!</button>');

  // Print to console.
  print(const JsonEncoder.withIndent('  ').convert(node));
}
