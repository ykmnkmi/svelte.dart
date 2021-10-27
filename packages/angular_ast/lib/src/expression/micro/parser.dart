import 'package:meta/meta.dart' show literal;

import '../../parser_exception.dart';
import '../../ast.dart';
import 'ast.dart';
import 'lexer.dart';
import 'token.dart';

class MicroParser {
  @literal
  const MicroParser();

  MicroAST parse(String directive, String? expression, int? expressionOffset,
      {required String sourceUrl, Node? origin}) {
    var paddedExpression = ' ' * expressionOffset! + expression!;
    var tokens = const MicroLexer().tokenize(paddedExpression).iterator;
    return RecursiveMicroASTParser(directive, expressionOffset, expression.length, tokens, origin).parse();
  }
}

class RecursiveMicroASTParser {
  RecursiveMicroASTParser(this.directive, this.expressionOffset, this.expressionLength, this.tokens, this.origin)
      : letBindings = <LetBinding>[],
        properties = <Property>[];

  final String directive;

  final int? expressionOffset;

  final int? expressionLength;

  // final String sourceUrl;

  final Iterator<MicroToken> tokens;

  final List<LetBinding> letBindings;

  final List<Property> properties;

  final Node? origin;

  MicroAST parse() {
    // Only the first token can be bound to the left-hand side property.
    var first = true;

    while (tokens.moveNext()) {
      var token = tokens.current;

      if (token.type == MicroTokenType.letKeyword) {
        parseLet();
      } else if (token.type == MicroTokenType.bindIdentifier) {
        parseBind();
      } else if (token.type == MicroTokenType.bindExpression && first) {
        parseImplicitBind();
      } else if (token.type != MicroTokenType.endExpression) {
        throw unexpected(token);
      }

      first = false;
    }

    return MicroAST(letBindings, properties);
  }

  void parseBind() {
    var name = tokens.current.lexeme;

    if (!tokens.moveNext() ||
        tokens.current.type != MicroTokenType.bindExpressionBefore ||
        !tokens.moveNext() ||
        tokens.current.type != MicroTokenType.bindExpression) {
      throw unexpected();
    }

    var value = tokens.current.lexeme;
    properties.add(Property.from(origin, '$directive${name[0].toUpperCase()}${name.substring(1)}', value));
  }

  // An implicit binding has no accompanying identifier. Instead, it is bound
  // to the property on the left-hand side to which the micro-syntax expression
  // was assigned.
  void parseImplicitBind() {
    properties.add(Property.from(origin, directive, tokens.current.lexeme));
  }

  void parseLet() {
    String identifier;

    if (!tokens.moveNext() ||
        tokens.current.type != MicroTokenType.letKeywordAfter ||
        !tokens.moveNext() ||
        tokens.current.type != MicroTokenType.letIdentifier) {
      throw unexpected();
    }

    identifier = tokens.current.lexeme;

    if (!tokens.moveNext() ||
        tokens.current.type == MicroTokenType.endExpression ||
        !tokens.moveNext() ||
        tokens.current.type == MicroTokenType.endExpression) {
      letBindings.add(LetBinding.from(origin, identifier));
      return;
    }

    if (tokens.current.type == MicroTokenType.letAssignment) {
      letBindings.add(LetBinding.from(origin, identifier, tokens.current.lexeme.trimRight()));
    } else {
      letBindings.add(LetBinding.from(origin, identifier));

      if (tokens.current.type != MicroTokenType.bindIdentifier) {
        throw unexpected();
      }

      var property = tokens.current.lexeme;

      if (!tokens.moveNext() ||
          tokens.current.type != MicroTokenType.bindExpressionBefore ||
          !tokens.moveNext() ||
          tokens.current.type != MicroTokenType.bindExpression) {
        throw unexpected();
      }

      var expression = tokens.current.lexeme;
      properties
          .add(Property.from(origin, '$directive${property[0].toUpperCase()}${property.substring(1)}', expression));
    }
  }

  ParserException unexpected([MicroToken? token]) {
    token ??= tokens.current;
    return ParserException(ParserErrorCode.invalidMicroExpression, expressionOffset, expressionLength);
  }
}
