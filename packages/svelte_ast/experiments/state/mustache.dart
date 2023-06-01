// ignore_for_file: depend_on_referenced_packages, directives_ordering

import 'package:_fe_analyzer_shared/src/parser/parser_impl.dart'
    show PatternContext;
import 'package:_fe_analyzer_shared/src/scanner/token.dart'
    show Token, TokenType, Keyword;
import 'package:analyzer/dart/ast/ast.dart'
    show AssignmentExpression, DartPattern, Expression, SimpleIdentifier;
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';

import '../parser.dart';
import 'text.dart';

bool _isElse(Token token) {
  return token.type == TokenType.COLON && token.next!.type == Keyword.ELSE;
}

bool _isEndIf(Token token) {
  return token.type == TokenType.SLASH && token.next!.type == Keyword.IF;
}

bool _isEndEach(Token token) {
  return token.type == TokenType.SLASH &&
      token.next!.type == TokenType.IDENTIFIER &&
      token.next!.lexeme == 'each';
}

extension MustacheParser on Parser {
  Node mustache() {
    Token open = expectToken(TokenType.OPEN_CURLY_BRACKET);
    int start = open.offset;
    return switch (token.type) {
      TokenType.HASH => _block(start),
      TokenType.AT => _at(start),
      _ => _expression(start),
    };
  }

  Node _block(int start) {
    expectToken(TokenType.HASH);
    return switch (token.type) {
      Keyword.IF => _ifBlock(start),
      TokenType.IDENTIFIER when token.lexeme == 'each' => _each(start),
      _ => throw StateError(token.type.name),
    };
  }

  IfBlock _ifBlock(int start) {
    expectToken(Keyword.IF);
    token = parser.syntheticPreviousToken(token);
    token = parser.parseExpression(token);
    nextToken();

    Expression test = astBuilder.pop() as Expression;
    DartPattern? case_;

    if (skipTokenIf(Keyword.CASE)) {
      token = parser.syntheticPreviousToken(token);
      token = parser.parsePattern(token, PatternContext.matching);
      nextToken();
      case_ = astBuilder.pop() as DartPattern;
    }

    Expression? when_;

    if (skipTokenIf(Keyword.WHEN)) {
      token = parser.syntheticPreviousToken(token);
      token = parser.parseExpression(token);
      nextToken();
      when_ = astBuilder.pop() as Expression;
    }

    List<Node> body = _body('if', (token) {
      return _isElse(token) || _isEndIf(token);
    });

    List<Node> orElse = const <Node>[];

    if (skipTokenIf(TokenType.COLON)) {
      expectToken(Keyword.ELSE);

      if (matchToken(TokenType.CLOSE_CURLY_BRACKET)) {
        orElse = _body('ifElse', _isEndIf);
        expectToken(TokenType.SLASH);
        expectToken(Keyword.IF);
        expectToken(TokenType.CLOSE_CURLY_BRACKET);
      } else {
        orElse = <Node>[_ifBlock(token.end)];
      }
    } else {
      expectToken(TokenType.SLASH);
      expectToken(Keyword.IF);
      expectToken(TokenType.CLOSE_CURLY_BRACKET);
    }

    return IfBlock(
        start: start,
        end: token.end,
        test: test,
        case_: case_,
        when_: when_,
        body: body,
        orElse: orElse);
  }

  EachBlock _each(int start) {
    expectToken(TokenType.IDENTIFIER, 'each');
    token = parser.syntheticPreviousToken(token);
    token = parser.parsePattern(token, PatternContext.assignment);
    nextToken();

    DartPattern context = astBuilder.pop() as DartPattern;

    expectToken(Keyword.IN);

    token = parser.syntheticPreviousToken(token);
    token = parser.parseExpression(token);
    nextToken();

    Expression iterable = astBuilder.pop() as Expression;

    if (skipTokenIf(TokenType.COMMA)) {}

    List<Node> body = _body('each', (token) {
      return _isElse(token) || _isEndEach(token);
    });

    List<Node> orElse = const <Node>[];

    if (skipTokenIf(TokenType.COLON)) {
      expectToken(Keyword.ELSE);
      orElse = _body('eachElse', _isEndEach);
    }

    expectToken(TokenType.SLASH);
    expectToken(TokenType.IDENTIFIER, 'each');
    expectToken(TokenType.CLOSE_CURLY_BRACKET);
    return EachBlock(
        start: start,
        end: token.end,
        context: context,
        iterable: iterable,
        body: body,
        orElse: orElse);
  }

  List<Node> _body(String tag, bool Function(Token token) end) {
    expectToken(TokenType.CLOSE_CURLY_BRACKET);

    List<Node> nodes = <Node>[];
    endTagsStack.add(tag);

    outer:
    while (token.type != TokenType.EOF) {
      if (token.type == TokenType.OPEN_CURLY_BRACKET) {
        Token next = token.next!;

        if (end(next)) {
          token = next;
          break outer;
        }

        nodes.add(mustache());
      } else if (text() case var node?) {
        nodes.add(node);
      }
    }

    if (endTagsStack.isEmpty || endTagsStack.removeLast() != tag) {
      throw StateError(tag);
    }

    if (token.type == TokenType.EOF) {
      throw StateError('EOF');
    }

    return nodes;
  }

  Node _at(int start) {
    expectToken(TokenType.AT);
    return switch (token.type) {
      TokenType.IDENTIFIER when token.lexeme == 'html' => _html(start),
      TokenType.IDENTIFIER when token.lexeme == 'debug' => _debug(start),
      Keyword.CONST => _const(start),
      _ => throw StateError(token.type.name),
    };
  }

  RawMustacheTag _html(int start) {
    expectToken(TokenType.IDENTIFIER, 'html');
    token = parser.syntheticPreviousToken(token);
    token = parser.parseExpression(token);
    nextToken();

    Expression value = astBuilder.pop() as Expression;
    Token close = expectToken(TokenType.CLOSE_CURLY_BRACKET);
    return RawMustacheTag(start: start, end: close.end, value: value);
  }

  DebugTag _debug(int start) {
    expectToken(TokenType.IDENTIFIER, 'debug');

    if (skipTokenIf(TokenType.CLOSE_CURLY_BRACKET)) {
      return DebugTag(start: start, end: token.end);
    }

    token = parser.syntheticPreviousToken(token);
    token = parser.parseIdentifierList(token);
    nextToken();

    List<SimpleIdentifier> identifiers =
        astBuilder.pop() as List<SimpleIdentifier>;
    Token close = expectToken(TokenType.CLOSE_CURLY_BRACKET);
    return DebugTag(start: start, end: close.end, identifiers: identifiers);
  }

  ConstTag _const(int start) {
    expectToken(Keyword.CONST);
    token = parser.syntheticPreviousToken(token);
    token = parser.parseExpression(token);
    nextToken();

    Object? assign = astBuilder.pop();

    if (assign is! AssignmentExpression) {
      error(invalidConstArgs, start);
    }

    Token close = expectToken(TokenType.CLOSE_CURLY_BRACKET);
    return ConstTag(start: start, end: close.end, assign: assign);
  }

  MustacheTag _expression(int start) {
    token = parser.syntheticPreviousToken(token);
    token = parser.parseExpression(token);
    nextToken();

    Expression value = astBuilder.pop() as Expression;
    Token close = expectToken(TokenType.CLOSE_CURLY_BRACKET);
    return MustacheTag(start: start, end: close.end, value: value);
  }
}
