// ignore_for_file: implementation_imports, depend_on_referenced_packages

import 'package:_fe_analyzer_shared/src/scanner/token.dart' show StringToken;
import 'package:analyzer/dart/ast/ast.dart' show Identifier;
import 'package:analyzer/dart/ast/token.dart' show TokenType;
import 'package:analyzer/src/dart/ast/ast_factory.dart' show astFactory;
import 'package:nutty/src/compiler/parser/parser.dart';

extension ContextParser on Parser {
  Identifier readContext() {
    var start = index;
    var identifier = readIdentifier();

    if (identifier == null) {
      error('parse-error', 'identifier expected');
    }

    var token = StringToken(TokenType.IDENTIFIER, identifier, start);
    return astFactory.simpleIdentifier(token);
  }
}
