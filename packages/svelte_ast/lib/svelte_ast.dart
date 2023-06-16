import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/parser.dart';

export 'package:svelte_ast/src/ast.dart';
export 'package:svelte_ast/src/errors.dart' show ParseError;

Node parse(String string, {String? fileName, Uri? uri}) {
  Parser parser = Parser(string: string, fileName: fileName, uri: uri);
  return parser.html;
}
