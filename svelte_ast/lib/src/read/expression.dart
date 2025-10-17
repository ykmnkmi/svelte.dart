// ignore_for_file: implementation_imports

import 'package:_fe_analyzer_shared/src/parser/member_kind.dart' as dart;
import 'package:_fe_analyzer_shared/src/parser/parser_impl.dart' as dart;
import 'package:_fe_analyzer_shared/src/scanner/scanner.dart' as dart;
import 'package:analyzer/dart/ast/token.dart' as dart;
import 'package:analyzer/diagnostic/diagnostic.dart' as dart;
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

    return dart.SimpleIdentifierImpl(token: token);
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

  dart.DartPattern _readPattern(
    Pattern closingPattern,
    dart.PatternContext context,
  ) {
    try {
      return parseString<dart.DartPattern>(
        offset: position,
        string: template,
        closingPattern: closingPattern,
        fileName: fileName,
        uri: uri,
        parse: (token, parser) {
          parser.fastaParser.parsePattern(
            parser.fastaParser.syntheticPreviousToken(token),
            context,
          );

          Object? pattern = parser.astBuilder.pop();

          if (pattern is! dart.DartPattern) {
            // TODO(ast): add error function.
            dartError('Expected a pattern.', token.offset);
          }

          position = pattern.end;
          return pattern;
        },
      );
    } on dart.Diagnostic catch (error) {
      dartError(error.message, error.offset);
    }
  }

  List<dart.SimpleIdentifier> readIdentifierList(Pattern closingPattern) {
    try {
      return parseString<List<dart.SimpleIdentifier>>(
        offset: position,
        string: template,
        closingPattern: closingPattern,
        fileName: fileName,
        uri: uri,
        parse: (token, parser) {
          parser.fastaParser.parseIdentifierList(
            parser.fastaParser.syntheticPreviousToken(token),
          );

          Object? identifiers = parser.astBuilder.pop();

          if (identifiers is! List<dart.SimpleIdentifier>) {
            // TODO(ast): add error function.
            dartError('Expected parameters.', token.offset);
          }

          if (identifiers.isNotEmpty) {
            position = identifiers.last.end;
          }

          return identifiers;
        },
      );
    } on dart.Diagnostic catch (error) {
      dartError(error.message, error.offset);
    }
  }

  dart.FormalParameterList readParameters(Pattern closingPattern) {
    try {
      return parseString<dart.FormalParameterList>(
        offset: position,
        string: template,
        closingPattern: closingPattern,
        fileName: fileName,
        uri: uri,
        parse: (token, parser) {
          parser.fastaParser.parseFormalParameters(
            parser.fastaParser.syntheticPreviousToken(token),
            dart.MemberKind.Local,
          );

          Object? parameters = parser.astBuilder.pop();

          if (parameters is! dart.FormalParameterList) {
            // TODO(ast): add error function.
            dartError('Expected parameters.', token.offset);
          }

          position = parameters.end;
          return parameters;
        },
      );
    } on dart.Diagnostic catch (error) {
      dartError(error.message, error.offset);
    }
  }

  dart.Expression readExpression(Pattern closingPattern) {
    try {
      return parseString<dart.Expression>(
        offset: position,
        string: template,
        closingPattern: closingPattern,
        fileName: fileName,
        uri: uri,
        parse: (token, parser) {
          parser.fastaParser.parseExpression(
            parser.fastaParser.syntheticPreviousToken(token),
          );

          Object? expression = parser.astBuilder.pop();

          if (expression is! dart.Expression) {
            // TODO(ast): add error function.
            dartError('Expected an expression.', token.offset);
          }

          position = expression.end;
          return expression;
        },
      );
    } on dart.Diagnostic catch (error) {
      dartError(error.message, error.offset);
    }
  }
}
