// ignore_for_file: depend_on_referenced_packages, directives_ordering, implementation_imports

import 'package:_fe_analyzer_shared/src/parser/parser_impl.dart'
    show PatternContext;
import 'package:_fe_analyzer_shared/src/scanner/token.dart'
    show Token, TokenType, Keyword;
import 'package:analyzer/dart/ast/ast.dart'
    show AssignmentExpression, DartPattern, Expression, SimpleIdentifier;
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/parser.dart';
import 'package:svelte_ast/src/scanner.dart';
import 'package:svelte_ast/src/state/text.dart';

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

bool _isThen(Token token) {
  return token.type == TokenType.COLON &&
      token.next!.type == TokenType.IDENTIFIER &&
      token.next!.lexeme == 'then';
}

bool _isCatch(Token token) {
  return token.type == TokenType.COLON && token.next!.type == Keyword.CATCH;
}

bool _isEndAwait(Token token) {
  return token.type == TokenType.SLASH && token.next!.type == Keyword.AWAIT;
}

bool _isEndKey(Token token) {
  return token.type == TokenType.SLASH &&
      token.next!.type == TokenType.IDENTIFIER &&
      token.next!.lexeme == 'key';
}

List<Node> _trimNodes(List<Node> nodes, bool before, bool after) {
  if (nodes.isEmpty) {
    return nodes;
  }

  nodes = List<Node>.of(nodes);

  if (nodes.first case Text text when before) {
    String data = text.data.trimLeft();

    if (data.isEmpty) {
      nodes.removeAt(0);
    } else {
      text.data = data.trimLeft();
    }
  }

  if (nodes.isNotEmpty) {
    if (nodes.last case Text text when before) {
      String data = text.data.trimLeft();

      if (data.isEmpty) {
        nodes.removeLast();
      } else {
        text.data = data.trimRight();
      }
    }
  }

  return nodes;
}

extension MustacheParser on Parser {
  Node mustache() {
    Token open = expectToken(TokenType.OPEN_CURLY_BRACKET);
    return switch (token.type) {
      TokenType.HASH => _block(open),
      TokenType.AT => _at(open),
      _ => _expression(open),
    };
  }

  Node _block(Token start) {
    expectToken(TokenType.HASH);
    return switch (token.type) {
      Keyword.IF => _ifBlock(start),
      TokenType.IDENTIFIER when token.lexeme == 'each' => _eachBlock(start),
      Keyword.AWAIT => _awaitBlock(start),
      TokenType.IDENTIFIER when token.lexeme == 'key' => _keyBlock(start),
      _ => throw StateError(token.type.name),
    };
  }

  IfBlock _ifBlock(Token open) {
    expectToken(Keyword.IF);

    token = parser.syntheticPreviousToken(token);
    token = parser.parseExpression(token);
    Expression test = astBuilder.pop() as Expression;
    nextToken();

    DartPattern? case_;

    if (skipNextTokenIf(Keyword.CASE)) {
      token = parser.syntheticPreviousToken(token);
      token = parser.parsePattern(token, PatternContext.matching);
      case_ = astBuilder.pop() as DartPattern;
      nextToken();
    }

    Expression? when;

    if (skipNextTokenIf(Keyword.WHEN)) {
      token = parser.syntheticPreviousToken(token);
      token = parser.parseExpression(token);
      when = astBuilder.pop() as Expression;
      nextToken();
    }

    List<Node> body = _body('if', (token) {
      return _isElse(token) || _isEndIf(token);
    });

    List<Node>? orElse;

    if (skipNextTokenIf(TokenType.COLON)) {
      expectToken(Keyword.ELSE);

      if (matchToken(TokenType.CLOSE_CURLY_BRACKET)) {
        orElse = _body('ifElse', _isEndIf);
        expectToken(TokenType.SLASH);
        expectToken(Keyword.IF);
        expectToken(TokenType.CLOSE_CURLY_BRACKET);
      } else {
        orElse = <Node>[_ifBlock(token.next!)];
      }
    } else {
      expectToken(TokenType.SLASH);
      expectToken(Keyword.IF);
      expectToken(TokenType.CLOSE_CURLY_BRACKET);
    }

    return IfBlock(
        start: open.offset,
        end: token.end,
        test: test,
        case_: case_,
        when_: when,
        body: body,
        orElse: orElse);
  }

  EachBlock _eachBlock(Token open) {
    expectToken(TokenType.IDENTIFIER, 'each');

    token = parser.syntheticPreviousToken(token);
    token = parser.parsePattern(token, PatternContext.assignment);
    DartPattern context = astBuilder.pop() as DartPattern;
    nextToken();

    expectToken(Keyword.IN);

    token = parser.syntheticPreviousToken(token);
    token = parser.parseExpression(token);
    Expression iterable = astBuilder.pop() as Expression;
    nextToken();

    String? index;

    if (skipNextTokenIf(TokenType.COMMA)) {
      Token identifierToken = expectToken(TokenType.IDENTIFIER);
      index = identifierToken.lexeme;
    }

    Expression? key;

    if (skipNextTokenIf(TokenType.OPEN_PAREN)) {
      token = parser.syntheticPreviousToken(token);
      token = parser.parseExpression(token);
      key = astBuilder.pop() as Expression;
      nextToken();
      expectToken(TokenType.CLOSE_PAREN);
    }

    List<Node> body = _body('each', (token) {
      return _isElse(token) || _isEndEach(token);
    });

    List<Node>? orElse;

    if (skipNextTokenIf(TokenType.COLON)) {
      expectToken(Keyword.ELSE);
      orElse = _body('eachElse', _isEndEach);
    }

    expectToken(TokenType.SLASH);
    expectToken(TokenType.IDENTIFIER, 'each');
    expectToken(TokenType.CLOSE_CURLY_BRACKET);
    return EachBlock(
        start: open.offset,
        end: token.end,
        context: context,
        iterable: iterable,
        index: index,
        key: key,
        body: body,
        orElse: orElse);
  }

  AwaitBlock _awaitBlock(Token open) {
    token = parser.syntheticPreviousToken(token);
    token = parser.parseExpression(token);
    Expression future = astBuilder.pop() as Expression;
    nextToken();

    List<Node>? futureBody;

    if (token.type == TokenType.CLOSE_CURLY_BRACKET) {
      futureBody = _body('awaitFuture', (token) {
        return _isThen(token) || _isCatch(token) || _isEndAwait(token);
      });
    }

    String? then_;
    List<Node>? thenBody;

    if (skipNextTokenIf(TokenType.IDENTIFIER, 'then') ||
        _isThen(token) && skipToken(2)) {
      Token identifierToken = expectToken(TokenType.IDENTIFIER);
      then_ = identifierToken.lexeme;
    }

    if (then_ != null) {
      thenBody = _body('awaitThen', (token) {
        return _isCatch(token) || _isEndAwait(token);
      });
    }

    String? catch_;
    List<Node>? catchBody;

    if (skipNextTokenIf(Keyword.CATCH) || _isCatch(token) && skipToken(2)) {
      Token identifierToken = expectToken(TokenType.IDENTIFIER);
      catch_ = identifierToken.lexeme;
    }

    if (catch_ != null) {
      catchBody = _body('awaitCatch', _isEndAwait);
    }

    expectToken(TokenType.SLASH);
    expectToken(Keyword.AWAIT);
    expectToken(TokenType.CLOSE_CURLY_BRACKET);
    return AwaitBlock(
        start: open.offset,
        end: token.end,
        future: future,
        futureBody: futureBody,
        then_: then_,
        thenBody: thenBody,
        catch_: catch_,
        catchBody: catchBody);
  }

  KeyBlock _keyBlock(Token open) {
    expectToken(TokenType.IDENTIFIER, 'key');

    token = parser.syntheticPreviousToken(token);
    token = parser.parsePattern(token, PatternContext.assignment);
    Expression key = astBuilder.pop() as Expression;
    nextToken();

    List<Node> body = _body('key', _isEndKey);
    expectToken(TokenType.SLASH);
    expectToken(TokenType.IDENTIFIER, 'key');
    expectToken(TokenType.CLOSE_CURLY_BRACKET);
    return KeyBlock(
      start: open.offset,
      end: token.end,
      key: key,
      children: body,
    );
  }

  List<Node> _body(String tag, bool Function(Token token) end) {
    expectToken(TokenType.CLOSE_CURLY_BRACKET);

    List<Node> nodes = <Node>[];
    String endTag = '$tag-${token.offset}';
    endTagsStack.add(endTag);

    outer:
    while (token.type != TokenType.EOF) {
      if (token.type == TokenType.OPEN_CURLY_BRACKET) {
        Token next = token.next!;

        if (end(next)) {
          token = next;
          break outer;
        }

        nodes.add(mustache());
      } else if (token.type == SvelteToken.DATA) {
        nodes.add(text());
      }
    }

    if (endTagsStack.isEmpty || endTagsStack.removeLast() != endTag) {
      throw StateError('Expected token type $tag, got $token.');
    }

    if (token.type == TokenType.EOF) {
      throw StateError('EOF');
    }

    return nodes;
  }

  Node _at(Token open) {
    expectToken(TokenType.AT);
    return switch (token.type) {
      TokenType.IDENTIFIER when token.lexeme == 'html' => _html(open),
      TokenType.IDENTIFIER when token.lexeme == 'debug' => _debug(open),
      Keyword.CONST => _const(open),
      _ => throw StateError(token.type.name),
    };
  }

  RawMustacheTag _html(Token open) {
    expectToken(TokenType.IDENTIFIER, 'html');
    token = parser.syntheticPreviousToken(token);
    token = parser.parseExpression(token);
    nextToken();

    Expression value = astBuilder.pop() as Expression;
    Token close = expectToken(TokenType.CLOSE_CURLY_BRACKET);
    return RawMustacheTag(
        start: open.offset, end: close.end, expression: value);
  }

  DebugTag _debug(Token open) {
    expectToken(TokenType.IDENTIFIER, 'debug');

    List<SimpleIdentifier>? identifiers;

    if (!skipNextTokenIf(TokenType.CLOSE_CURLY_BRACKET)) {
      token = parser.syntheticPreviousToken(token);
      token = parser.parseIdentifierList(token);
      nextToken();
      identifiers = astBuilder.pop() as List<SimpleIdentifier>;
    }

    Token close = expectToken(TokenType.CLOSE_CURLY_BRACKET);
    return DebugTag(
        start: open.offset, end: close.end, identifiers: identifiers);
  }

  ConstTag _const(Token open) {
    expectToken(Keyword.CONST);
    token = parser.syntheticPreviousToken(token);
    token = parser.parseExpression(token);
    nextToken();

    Object? assign = astBuilder.pop();

    if (assign is! AssignmentExpression) {
      error(invalidConstArgs, open.offset);
    }

    Token close = expectToken(TokenType.CLOSE_CURLY_BRACKET);
    return ConstTag(start: open.offset, end: close.end, assign: assign);
  }

  MustacheTag _expression(Token open) {
    token = parser.syntheticPreviousToken(token);
    token = parser.parseExpression(token);
    nextToken();

    Expression value = astBuilder.pop() as Expression;
    Token close = expectToken(TokenType.CLOSE_CURLY_BRACKET);
    return MustacheTag(start: open.offset, end: close.end, expression: value);
  }
}
