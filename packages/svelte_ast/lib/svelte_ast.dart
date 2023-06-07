import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/parser.dart';

export 'package:svelte_ast/src/ast.dart';
export 'package:svelte_ast/src/errors.dart' show ParseError;

Node parse(String source, {String? fullName, Uri? uri}) {
  return Parser(source, fullName: fullName, uri: uri).parse();
}
