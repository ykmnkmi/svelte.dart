// ignore_for_file: implementation_imports

import 'package:_fe_analyzer_shared/src/parser/parser_impl.dart' as dart;
import 'package:_fe_analyzer_shared/src/scanner/scanner.dart' as dart;
import 'package:analyzer/dart/ast/token.dart' as dart;
import 'package:analyzer/src/dart/ast/ast.dart' as dart;
import 'package:svelte_ast/src/parser.dart';
import 'package:svelte_ast/src/read/dart/parser.dart';

extension ExpressionParser on Parser {
  dart.SimpleIdentifier simpleIdentifier(int start, String name) {
    dart.Token token = dart.StringTokenImpl.fromString(
      dart.TokenType.IDENTIFIER,
      name,
      start,
    );

    return dart.SimpleIdentifierImpl(token);
  }

  dart.StringLiteral simpleString(int start, String value) {
    dart.Token token = dart.StringTokenImpl.fromString(
      dart.TokenType.STRING,
      value,
      start,
    );

    return dart.SimpleStringLiteralImpl(literal: token, value: value);
  }

  dart.DartPattern readAssignmentPattern(Pattern end) {
    return _readPattern(end, dart.PatternContext.assignment);
  }

  dart.DartPattern _readPattern(Pattern end, dart.PatternContext context) {
    return parseString<dart.DartPattern>(
      offset: index,
      string: template,
      closingPattern: end,
      fileName: fileName,
      uri: uri,
      parse: (token, parser) {
        parser.fastaParser.parsePattern(
          parser.fastaParser.syntheticPreviousToken(token),
          context,
        );

        Object? pattern = parser.astBuilder.pop();

        if (pattern is! dart.DartPattern) {
          dartError('Expected a pattern.', token.offset);
        }

        index = pattern.end;
        return pattern;
      },
    );
  }

  dart.Expression readExpression(Pattern end) {
    return parseString<dart.Expression>(
      offset: index,
      string: template,
      closingPattern: end,
      fileName: fileName,
      uri: uri,
      parse: (token, parser) {
        parser.fastaParser.parseExpression(
          parser.fastaParser.syntheticPreviousToken(token),
        );

        Object? expression = parser.astBuilder.pop();

        if (expression is! dart.Expression) {
          dartError('Expected an expression.', token.offset);
        }

        index = expression.end;
        return expression;
      },
    );
  }
}
