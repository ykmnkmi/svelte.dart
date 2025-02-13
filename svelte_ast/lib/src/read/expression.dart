// ignore_for_file: implementation_imports

import 'package:_fe_analyzer_shared/src/messages/codes.dart';
import 'package:_fe_analyzer_shared/src/parser/parser_impl.dart' hide Parser;
import 'package:_fe_analyzer_shared/src/scanner/scanner.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:svelte_ast/src/parser.dart';
import 'package:svelte_ast/src/read/script_parser.dart';

final RegExp _identifierRe = RegExp('[_\$A-Za-z][_\$A-Za-z0-9]*');

extension ExpressionParser on Parser {
  String? readIdentifier() {
    return read(_identifierRe);
  }

  DartPattern readAssignmentPattern(Pattern end) {
    return readPattern(end, PatternContext.assignment);
  }

  DartPattern readPattern(Pattern end, PatternContext context) {
    void callback(ScriptParser parser, Token token) {
      token = parser.syntheticPreviousToken(token);
      token = parser.parsePattern(token, context);
      position = token.end;
    }

    return withScriptParser<DartPattern>(position, end, callback);
  }

  Expression readExpression(Pattern end) {
    void callback(ScriptParser parser, Token token) {
      token = parser.syntheticPreviousToken(token);
      token = parser.parseExpression(token);
      position = token.end;
    }

    return withScriptParser<Expression>(position, end, callback);
  }

  SimpleIdentifier simpleIdentifier(int start, String name) {
    Token token = StringTokenImpl.fromString(TokenType.IDENTIFIER, name, start);
    return SimpleIdentifierImpl(token);
  }

  T withScriptParser<T>(
    int offset,
    Pattern end,
    ScriptParserCallback callback,
  ) {
    ScriptParser parser = ScriptParser.fromString(
      string: string,
      offset: offset,
      fileName: fileName,
      uri: uri,
    );

    try {
      Token token = parser.scanner.scan(end);
      callback(parser, token);
      return parser.builder.pop() as T;
    } on AnalysisError catch (analysisError) {
      var AnalysisError(
        offset: int offset,
        length: int length,
        message: String message,
      ) = analysisError;
      dartError(message, offset, length);
    } on ErrorToken catch (token) {
      var ErrorToken(:int offset, :int length, :Message assertionMessage) =
          token;
      dartError(assertionMessage.problemMessage, offset, length);
    }
  }

  void withScriptParserRun(
    int offset,
    Pattern end,
    ScriptParserCallback callback,
  ) {
    ScriptParser parser = ScriptParser.fromString(
      string: string,
      offset: offset,
      fileName: fileName,
      uri: uri,
    );

    try {
      Token token = parser.scanner.scan(end);
      callback(parser, token);
    } on AnalysisError catch (analysisError) {
      var AnalysisError(
        offset: int offset,
        length: int length,
        message: String message,
      ) = analysisError;
      dartError(message, offset, length);
    } on ErrorToken catch (token) {
      var ErrorToken(
        offset: int offset,
        length: int length,
        assertionMessage: Message assertionMessage,
      ) = token;
      dartError(assertionMessage.problemMessage, offset, length);
    }
  }
}
