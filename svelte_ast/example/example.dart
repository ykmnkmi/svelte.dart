// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:svelte_ast/svelte_ast.dart';

const String content = '''
<p>Hello <span>World</span>!</p>''';

void main() {
  // Create an AST tree by parsing an SvelteDart template.
  Root root = parse(content);

  // Print to console.
  print(const JsonEncoder.withIndent('  ').convert(root.toJson()));
}
