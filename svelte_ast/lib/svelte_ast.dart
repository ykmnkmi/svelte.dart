import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/parser.dart';

export 'package:svelte_ast/src/ast.dart';
export 'package:svelte_ast/src/errors.dart' show ParseError;
export 'package:svelte_ast/src/visitor.dart';

Root parse(String string, {String? fileName, Uri? uri, bool loose = false}) {
  return Parser(
    template: string.trimRight(),
    fileName: fileName,
    uri: uri,
    loose: loose,
  ).root;
}
