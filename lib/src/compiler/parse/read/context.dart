import 'package:analyzer/dart/ast/ast.dart' show Identifier;
import 'package:analyzer/dart/ast/token.dart' show Token, TokenType;
import 'package:analyzer/src/dart/ast/ast_factory.dart' show astFactory;
import 'package:piko/src/compiler/parse/parse.dart';
import 'package:piko/src/compiler/utils/patterns.dart';

extension ContextParser on Parser {
  static final RegExp closeRe = compile(r'<\/style\s*>');

  static final RegExp allRe = compile(r'[^\n]');

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
