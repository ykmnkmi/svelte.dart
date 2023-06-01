import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/parser.dart';

export 'package:svelte_ast/src/ast.dart';

Node parse(String template, {Object? url}) {
  return Parser(template.trimRight(), url: url).parse();
}
