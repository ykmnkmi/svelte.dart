import 'package:analyzer/dart/ast/ast.dart' show Identifier;
import 'package:analyzer/dart/ast/standard_ast_factory.dart' show astFactory;
import 'package:analyzer/dart/ast/token.dart' show Token, TokenType;

import '../../utils/patterns.dart';
import '../parse.dart';

extension ContextParser on Parser {
  static late final RegExp closeRe = compile(r'<\/style\s*>');

  // static late final RegExp allRe = compile(r'[^\n]');

  Identifier readContext() {
    var start = index;
    var identifier = readIdentifier();

    if (identifier == null) {
      error('parse-error', 'identifier expected');
    }

    var tokenType = TokenType(identifier, 'IDENTIFIER', 0, 97);
    var token = Token(tokenType, start);
    return astFactory.simpleIdentifier(token);
  }
}
